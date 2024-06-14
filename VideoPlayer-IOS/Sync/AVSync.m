//
//  AVSync.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#import <Foundation/Foundation.h>
#import "AVSync.h"
#import "VideoDecoder.h"
#import <UIKit/UIDevice.h>
#import <pthread.h>

#define LOCAL_MIN_BUFFERED_DURATION                     0.5
#define LOCAL_MAX_BUFFERED_DURATION                     1.0
#define NETWORK_MIN_BUFFERED_DURATION                   2.0
#define NETWORK_MAX_BUFFERED_DURATION                   4.0
#define LOCAL_AV_SYNC_MAX_TIME_DIFF                     0.05
#define FIRST_BUFFER_DURATION                           0.5

NSString * const kMIN_BUFFERED_DURATION = @"Min_Buffered_Duration";
NSString * const kMAX_BUFFERED_DURATION = @"Max_Buffered_Duration";

@interface AVSynchronizer () {
    
    VideoDecoder*                                       _decoder;
    BOOL                                                isOnDecoding;
    BOOL                                                isInitializeDecodeThread;
    BOOL                                                isDestroyed;
    
    BOOL                                                isFirstScreen;
    /** 解码第一段buffer的控制变量 **/
    pthread_mutex_t                                     decodeFirstBufferLock;
    pthread_cond_t                                      decodeFirstBufferCondition;
    pthread_t                                           decodeFirstBufferThread;
    /** 是否正在解码第一段buffer **/
    BOOL                                                isDecodingFirstBuffer;
    
    pthread_mutex_t                                     videoDecoderLock;
    pthread_cond_t                                      videoDecoderCondition;
    pthread_t                                           videoDecoderThread;
    
//    dispatch_queue_t                                    _dispatchQueue;
    NSMutableArray*                                     _videoFrames;
    NSMutableArray*                                     _audioFrames;
    
    /** 分别是当外界需要音频数据和视频数据的时候, 全局变量缓存数据 **/
    NSData*                                             _currentAudioFrame;
    NSUInteger                                          _currentAudioFramePos;
    CGFloat                                             _audioPosition;
    VideoFrame*                                         _currentVideoFrame;
    
    /** 控制何时该解码 **/
    BOOL                                                _buffered;
    CGFloat                                             _bufferedDuration;
    CGFloat                                             _minBufferedDuration;
    CGFloat                                             _maxBufferedDuration;
    
    CGFloat                                             _syncMaxTimeDiff;
    NSInteger                                           _firstBufferDuration;
    
    BOOL                                                _completion;
    
    NSTimeInterval                                      _bufferedBeginTime;
    NSTimeInterval                                      _bufferedTotalTime;
    
    int                                                 _decodeVideoErrorState;
    NSTimeInterval                                      _decodeVideoErrorBeginTime;
    NSTimeInterval                                      _decodeVideoErrorTotalTime;
}

@end

@implementation AVSynchronizer

static void* decodeFirstBufferRunLoop(void* ptr)
{
    AVSynchronizer* synchronizer = (__bridge AVSynchronizer*)ptr;
    [synchronizer decodeFirstBuffer];
    return NULL;
}

static void* runDecoderThread(void* ptr)
{
    AVSynchronizer* synchronizer = (__bridge AVSynchronizer*)ptr;
    [synchronizer run];
    return NULL;
}

- (void) decodeFirstBuffer
{
    double startDecodeFirstBufferTimeMills = CFAbsoluteTimeGetCurrent() * 1000;
    [self decodeFramesWithDuration:FIRST_BUFFER_DURATION];
    int wasteTimeMills = CFAbsoluteTimeGetCurrent() * 1000 - startDecodeFirstBufferTimeMills;
    NSLog(@"Decode First Buffer waste TimeMills is %d", wasteTimeMills);
    pthread_mutex_lock(&decodeFirstBufferLock);
    pthread_cond_signal(&decodeFirstBufferCondition);
    pthread_mutex_unlock(&decodeFirstBufferLock);
    isDecodingFirstBuffer = false;
}

- (void) decodeFramesWithDuration:(CGFloat) duration;
{
    BOOL good = YES;
    while (good) {
        good = NO;
        @autoreleasepool {
            if (_decoder && (_decoder.validVideo || _decoder.validAudio)) {
                int tmpDecodeVideoErrorState;
                NSArray *frames = [_decoder decodeFrames:0.0f decodeVideoErrorState:&tmpDecodeVideoErrorState];
                if (frames.count) {
                    good = [self addFrames:frames duration:duration];
                }
            }
        }
    }
}

- (OpenState) openFile: (NSString *) path usingHWCodec: (BOOL) usingHWCodec error: (NSError **) perror;
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[FPS_PROBE_SIZE_CONFIGURED] = @(true);
    parameters[PROBE_SIZE] = @(50 * 1024);
    NSMutableArray* durations = [NSMutableArray array];
    durations[0] = @(1250000);
    durations[0] = @(1750000);
    durations[0] = @(2000000);
    parameters[MAX_ANALYZE_DURATION_ARRAY] = durations;
    return [self openFile:path parameters:parameters error:perror];
}

- (OpenState) openFile: (NSString *) path parameters:(NSDictionary*) parameters error: (NSError **) perror;
{
    //1、创建decoder实例
    [self createDecoderInstance];
    //2、初始化成员变量
    _currentVideoFrame = NULL;
    _currentAudioFramePos = 0;
    
    _bufferedBeginTime = 0;
    _bufferedTotalTime = 0;
    
    _decodeVideoErrorBeginTime = 0;
    _decodeVideoErrorTotalTime = 0;
    isFirstScreen = YES;
    
    _minBufferedDuration = [parameters[kMIN_BUFFERED_DURATION] floatValue];
    _maxBufferedDuration = [parameters[kMAX_BUFFERED_DURATION] floatValue];
    
    if (_minBufferedDuration > _maxBufferedDuration) {
        float temp = _minBufferedDuration;
        _minBufferedDuration = _maxBufferedDuration;
        _maxBufferedDuration = temp;
    }
    
    _syncMaxTimeDiff = LOCAL_AV_SYNC_MAX_TIME_DIFF;
    _firstBufferDuration = FIRST_BUFFER_DURATION;
    //3、打开流并且解析出来音视频流的Context
    BOOL openCode = [_decoder openFile:path parameter:parameters error:perror];
    if(!openCode || ![_decoder isSubscribed] || isDestroyed){
        NSLog(@"VideoDecoder decode file fail...");
        [self closeDecoder];
        return [_decoder isSubscribed] ? OPEN_FAILED : CLIENT_CANCEL;
    }
    //4、回调客户端视频宽高以及duration
    NSUInteger videoWidth = [_decoder frameWidth];
    NSUInteger videoHeight = [_decoder frameHeight];
    if(videoWidth <= 0 || videoHeight <= 0){
        return [_decoder isSubscribed] ? OPEN_FAILED : CLIENT_CANCEL;
    }
    //5、开启解码线程与解码队列
    _audioFrames        = [NSMutableArray array];
    _videoFrames        = [NSMutableArray array];
    [self startDecoderThread];
    [self startDecodeFirstBufferThread];
    return OPEN_SUCCESS;
}

- (void) startDecodeFirstBufferThread
{
    pthread_mutex_init(&decodeFirstBufferLock, NULL);
    pthread_cond_init(&decodeFirstBufferCondition, NULL);
    isDecodingFirstBuffer = true;
    
    pthread_create(&decodeFirstBufferThread, NULL, decodeFirstBufferRunLoop, (__bridge void*)self);
}

- (void) startDecoderThread {
    NSLog(@"AVSynchronizer::startDecoderThread ...");
    //    _dispatchQueue      = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
    
    isOnDecoding = true;
    isDestroyed = false;
    pthread_mutex_init(&videoDecoderLock, NULL);
    pthread_cond_init(&videoDecoderCondition, NULL);
    isInitializeDecodeThread = true;
    pthread_create(&videoDecoderThread, NULL, runDecoderThread, (__bridge void*)self);
}

- (void) createDecoderInstance
{
    _decoder = [[VideoDecoder alloc] init];
}

- (void) closeDecoder;
{
    if(_decoder){
        [_decoder closeFile];
        if(_playerStateDelegate && [_playerStateDelegate respondsToSelector:@selector(buriedPointCallback:)]){
            [_playerStateDelegate buriedPointCallback:[_decoder getBuriedPoint]];
        }
        _decoder = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames duration:(CGFloat) duration
{
    if (_decoder.validVideo) {
        @synchronized(_videoFrames) {
            for (Frame *frame in frames)
                if (frame.type == VideoFrameType) {
                    [_videoFrames addObject:frame];
                }
        }
    }
    
    if (_decoder.validAudio) {
        @synchronized(_audioFrames) {
            for (Frame *frame in frames)
                if (frame.type == AudioFrameType) {
                    [_audioFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    return _bufferedDuration < duration;
}


@end
