//
//  VideoDecoder.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#import <Foundation/Foundation.h>
#import "VideoDecoder.h"

@interface VideoDecoder () {
    
    AVFrame*                    _videoFrame;
    AVFrame*                    _audioFrame;
    
    CGFloat                     _fps;
    
    CGFloat                     _decodePosition;
    
    BOOL                        _isSubscribe;
    BOOL                        _isEOF;
    
    SwrContext*                 _swrContext;
    void*                       _swrBuffer;
    NSUInteger                  _swrBufferSize;
    
    AVPicture                   _picture;
    BOOL                        _pictureValid;
    struct SwsContext*          _swsContext;
    
    int                         _subscribeTimeOutTimeInSecs;
    int                         _readLastestFrameTime;
    
    BOOL                        _interrupted;
    
    int                         _connectionRetry;
}

@end

@implementation VideoDecoder

@end
