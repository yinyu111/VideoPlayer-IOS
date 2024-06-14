//
//  VideoOutput.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#import <Foundation/Foundation.h>
#import "VideoOutput.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "YUVFrameCopier.h"

@interface VideoOutput()

@property (atomic) BOOL readyToRender;
@property (nonatomic, assign) BOOL shouldEnableOpenGL;
@property (nonatomic, strong) NSLock *shouldEnableOpenGLLock;
@property (nonatomic, strong) NSOperationQueue *renderOperationQueue;

@end

@implementation VideoOutput
{
    EAGLContext*                            _context;
    GLuint                                  _displayFramebuffer;
    GLuint                                  _renderbuffer;
    GLint                                   _backingWidth;
    GLint                                   _backingHeight;
    
    BOOL                                    _stopping;
    
    YUVFrameCopier*                         _videoFrameCopier;
    
    //    BaseEffectFilter*                       _filter;
    
    //    DirectPassRenderer*                     _directPassRenderer;
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame textureWidth:(NSInteger)textureWidth textureHeight:(NSInteger)textureHeight {
    return [self initWithFrame:frame textureWidth:textureWidth textureHeight:textureHeight shareGroup:nil];
}

- (id) initWithFrame:(CGRect)frame textureWidth:(NSInteger)textureWidth textureHeight:(NSInteger)textureHeight  shareGroup:(EAGLSharegroup *)shareGroup
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldEnableOpenGLLock = [NSLock new];
        [_shouldEnableOpenGLLock lock];
        _shouldEnableOpenGL = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
        [_shouldEnableOpenGLLock unlock];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        _renderOperationQueue = [[NSOperationQueue alloc] init];
        _renderOperationQueue.maxConcurrentOperationCount = 1;
        _renderOperationQueue.name = @"com.kaku.videoplayer.videoRenderQueue";
        
        __weak VideoOutput *weakSelf = self;
        [_renderOperationQueue addOperationWithBlock:^{
            if (!weakSelf) {
                return;
            }
            
            __strong VideoOutput *strongSelf = weakSelf;
            if (shareGroup) {
                strongSelf->_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:shareGroup];
            } else {
                strongSelf->_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            }
            
            if (!strongSelf->_context || ![EAGLContext setCurrentContext:strongSelf->_context]) {
                NSLog(@"Setup EAGLContext Failed...");
            }
            if(![strongSelf createDisplayFramebuffer]){
                NSLog(@"create Dispaly Framebuffer failed...");
            }
            
            [strongSelf createCopierInstance];
            if (![strongSelf->_videoFrameCopier prepareRender:textureWidth height:textureHeight]) {
                NSLog(@"_videoFrameFastCopier prepareRender failed...");
            }
        }];
    }
    return self;
}

- (void) createCopierInstance
{
    _videoFrameCopier = [[YUVFrameCopier alloc] init];
}

static int count = 0;
- (void) presentVideoFrame:(VideoFrame*) frame;
{
    
}

- (BOOL) createDisplayFramebuffer;
{
    BOOL ret = TRUE;
    glGenFramebuffers(1, &_displayFramebuffer);
    glGenRenderbuffers(1, &_renderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return FALSE;
    }
    
    GLenum glError = glGetError();
    if (GL_NO_ERROR != glError) {
        NSLog(@"failed to setup GL %x", glError);
        return FALSE;
    }
    return ret;
}


- (void) destroy;
{
    _stopping = true;
    
    __weak VideoOutput *weakSelf = self;
    [self.renderOperationQueue addOperationWithBlock:^{
        if (!weakSelf) {
            return;
        }
        __strong VideoOutput *strongSelf = weakSelf;
        if(strongSelf->_videoFrameCopier) {
            [strongSelf->_videoFrameCopier releaseRender];
        }
        if (strongSelf->_displayFramebuffer) {
            glDeleteFramebuffers(1, &strongSelf->_displayFramebuffer);
            strongSelf->_displayFramebuffer = 0;
        }
        if (strongSelf->_renderbuffer) {
            glDeleteRenderbuffers(1, &strongSelf->_renderbuffer);
            strongSelf->_renderbuffer = 0;
        }
        if ([EAGLContext currentContext] == strongSelf->_context) {
            [EAGLContext setCurrentContext:nil];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_renderOperationQueue) {
        [_renderOperationQueue cancelAllOperations];
        _renderOperationQueue = nil;
    }
    
    _videoFrameCopier = nil;
    
    _context = nil;
    NSLog(@"Render Frame Count is %d", count);
}

@end
