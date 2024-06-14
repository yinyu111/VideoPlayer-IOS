//
//  VideoViewPlayerController.h
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#ifndef VideoViewPlayerController_h
#define VideoViewPlayerController_h

#import <UIKit/UIKit.h>
#import "VideoOutput.h"
#import "AVSync.h"
#import "AudioOutput.h"

@interface VideoPlayerViewController : UIViewController

@property(nonatomic, retain) AVSynchronizer*                synchronizer;
@property(nonatomic, retain) NSString*                      videoFilePath;
@property(nonatomic, weak) id<PlayerStateDelegate>          playerStateDelegate;


+ (instancetype)viewControllerWithContentPath:(NSString *)path
                            contentFrame:(CGRect)frame
                            playerStateDelegate:(id) playerStateDelegate
                            parameters: (NSDictionary *)parameters;

+ (instancetype)viewControllerWithContentPath:(NSString *)path
                                 contentFrame:(CGRect)frame
                          playerStateDelegate:(id<PlayerStateDelegate>) playerStateDelegate
                                   parameters: (NSDictionary *)parameters
                  outputEAGLContextShareGroup:(EAGLSharegroup *)sharegroup;

- (instancetype) initWithContentPath:(NSString *)path
              contentFrame:(CGRect)frame
       playerStateDelegate:(id) playerStateDelegate
                parameters:(NSDictionary *)parameters;

- (instancetype) initWithContentPath:(NSString *)path
                        contentFrame:(CGRect)frame
                 playerStateDelegate:(id) playerStateDelegate
                          parameters:(NSDictionary *)parameters
         outputEAGLContextShareGroup:(EAGLSharegroup *)sharegroup;

- (void)play;

- (void)pause;

- (void)stop;

- (void) restart;

- (BOOL) isPlaying;

- (UIImage *)movieSnapshot;

- (VideoOutput*) createVideoOutputInstance;
- (VideoOutput*) getVideoOutputInstance;
@end



#endif /* VideoViewPlayerController_h */
