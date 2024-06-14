//
//  AVSync.h
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#ifndef AVSync_h
#define AVSync_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "VideoDecoder.h"

typedef enum OpenState{
    OPEN_SUCCESS,
    OPEN_FAILED,
    CLIENT_CANCEL,
} OpenState;

// ---播放状态的代理，别的类会遵循这个代理，然后实现下边这些方法。主要是在播放的时候给界面发通知做出改变。
@protocol PlayerStateDelegate <NSObject>

- (void) openSucceed;

- (void) connectFailed;

- (void) hideLoading;

- (void) showLoading;

- (void) onCompletion;

- (void) buriedPointCallback:(BuriedPoint*) buriedPoint;

- (void) restart;

@end

@interface AVSynchronizer : NSObject

@property (nonatomic, weak) id<PlayerStateDelegate> playerStateDelegate;

//用于设置播放状态的代理，代理将接收播放状态的通知。
- (id) initWithPlayerStateDelegate:(id<PlayerStateDelegate>) playerStateDelegate;

- (OpenState) openFile: (NSString *) path
            parameters:(NSDictionary*) parameters error: (NSError **) perror;

- (OpenState) openFile: (NSString *) path
                 error: (NSError **) perror;

- (void) closeFile;


- (void) audioCallbackFillData: (SInt16 *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels;

- (VideoFrame*) getCorrectVideoFrame;

- (void) run;
- (BOOL) isOpenInputSuccess;
- (void) interrupt;

- (BOOL) usingHWCodec;

- (BOOL) isPlayCompleted;

- (NSInteger) getAudioSampleRate;
- (NSInteger) getAudioChannels;
- (CGFloat) getVideoFPS;
- (NSInteger) getVideoFrameHeight;
- (NSInteger) getVideoFrameWidth;
- (BOOL) isValid;
- (CGFloat) getDuration;

@end



#endif /* AVSync_h */
