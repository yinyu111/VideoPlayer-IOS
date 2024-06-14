//
//  VideoOutput.h
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#ifndef VideoOutput_h
#define VideoOutput_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VideoDecoder.h"
#import "BaseEffectFilter.h"

@interface VideoOutput : UIView

- (id) initWithFrame:(CGRect)frame textureWidth:(NSInteger)textureWidth textureHeight:(NSInteger)textureHeight;
- (id) initWithFrame:(CGRect)frame textureWidth:(NSInteger)textureWidth textureHeight:(NSInteger)textureHeight  shareGroup:(EAGLSharegroup *)shareGroup;

- (void) presentVideoFrame:(VideoFrame*) frame;

//- (BaseEffectFilter*) createImageProcessFilterInstance;
//- (BaseEffectFilter*) getImageProcessFilterInstance;

- (void) destroy;

@end

#endif /* VideoOutput_h */
