//
//  YUVFrameCopier.h
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#ifndef YUVFrameCopier_h
#define YUVFrameCopier_h

#import <Foundation/Foundation.h>
#import "BaseEffectFilter.h"
#import "VideoDecoder.h"

@interface YUVFrameCopier : BaseEffectFilter

- (void) renderWithTexId:(VideoFrame*) videoFrame;

@end

#endif /* YUVFrameCopier_h */
