//
//  AudioOutput.h
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#ifndef AudioOutput_h
#define AudioOutput_h

@protocol FillDataDelegate <NSObject>

- (NSInteger) fillAudioData:(SInt16*) sampleBuffer numFrames:(NSInteger)frameNum numChannels:(NSInteger)channels;

@end

@interface AudioOutput : NSObject

@property(nonatomic, assign) Float64 sampleRate;
@property(nonatomic, assign) Float64 channels;

- (id) initWithChannels:(NSInteger) channels sampleRate:(NSInteger) sampleRate bytesPerSample:(NSInteger) bytePerSample filleDataDelegate:(id<FillDataDelegate>) fillAudioDataDelegate;

- (BOOL) play;
- (void) stop;

@end

#endif /* AudioOutput_h */
