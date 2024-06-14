//
//  VideoViewPlayerController.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController () <FillDataDelegate> {
    VideoOutput*                                    _videoOutput;
//    AudioOutput*                                    _audioOutput;
//    NSDictionary*                                   _parameters;
    CGRect                                          _contentFrame;
    
    BOOL                                            _isPlaying;
    EAGLSharegroup *                                _shareGroup;
}

@end

@implementation VideoPlayerViewController

+ (id)viewControllerWithContentPath:(NSString *)path
                       contentFrame:(CGRect)frame;
{
    return [[VideoPlayerViewController alloc] initWithContentPath:path
                                                     contentFrame:frame];
}

- (id) initWithContentPath:(NSString *)path
              contentFrame:(CGRect)frame
{
    NSAssert(path.length > 0, @"empty path");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _contentFrame = frame;
        _videoFilePath = path;
        [self start];
    }
    return self;
}

// ---7.真正开始播
- (void) start
{
    // ---8.初始化播放状态的代理
//    _synchronizer = [[AVSynchronizer alloc] initWithPlayerStateDelegate:_playerStateDelegate];
    // ---9.解决循环引用的，因为下面有异步操作。
    __weak VideoPlayerViewController *weakSelf = self;
    BOOL isIOS8OrUpper = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
    dispatch_async(dispatch_get_global_queue(isIOS8OrUpper ? QOS_CLASS_USER_INTERACTIVE:DISPATCH_QUEUE_PRIORITY_HIGH, 0) , ^{
        __strong VideoPlayerViewController *strongSelf = weakSelf;
        if (strongSelf) {
            NSError *error = nil;
            OpenState state = OPEN_FAILED;
            // ---10.打开文件
            state = [strongSelf->_synchronizer openFile:_videoFilePath error:&error];
            if(OPEN_SUCCESS == state){
                //启动AudioOutput与VideoOutput
                _videoOutput = [strongSelf createVideoOutputInstance];
                _videoOutput.contentMode = UIViewContentModeScaleAspectFill;
                _videoOutput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.view.backgroundColor = [UIColor clearColor];
                    // ---16.把视频videoOutput界面插进来
                    [self.view insertSubview:_videoOutput atIndex:0];
                });
//                NSInteger audioChannels = [_synchronizer getAudioChannels];
//                NSInteger audioSampleRate = [_synchronizer getAudioSampleRate];
//                NSInteger bytesPerSample = 2;
//                _audioOutput = [[AudioOutput alloc] initWithChannels:audioChannels sampleRate:audioSampleRate bytesPerSample:bytesPerSample filleDataDelegate:self];
//                // ---17.音频开始播
//                [_audioOutput play];
                _isPlaying = YES;
                
                // ---18.之前说的代理，走到这以后会去ELVideoViewPlayerController里执行openSucceed
                if(_playerStateDelegate && [_playerStateDelegate respondsToSelector:@selector(openSucceed)]){
                    [_playerStateDelegate openSucceed];
                }
            } else if(OPEN_FAILED == state){
                if(_playerStateDelegate && [_playerStateDelegate respondsToSelector:@selector(connectFailed)]){
                    [_playerStateDelegate connectFailed];
                }
            }
        }
    });
}



@end
