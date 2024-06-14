//
//  BaseEffectFilter.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/14.
//

#import <Foundation/Foundation.h>
#import "BaseEffectFilter.h"

@implementation BaseEffectFilter

- (BOOL) prepareRender:(NSInteger) frameWidth height:(NSInteger) frameHeight;
{
    return NO;
}

//template method
- (void) renderWithWidth:(NSInteger) width height:(NSInteger) height position:(float)position {
    
}

- (BOOL) buildProgram:(NSString*) vertexShader fragmentShader:(NSString*) fragmentShader;
{
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    filterProgram = glCreateProgram();
    vertShader = compileShader(GL_VERTEX_SHADER, vertexShader);
    if (!vertShader)
        goto exit;
    fragShader = compileShader(GL_FRAGMENT_SHADER, fragmentShader);
    if (!fragShader)
        goto exit;
    
    glAttachShader(filterProgram, vertShader);
    glAttachShader(filterProgram, fragShader);
    
    glLinkProgram(filterProgram);
    
    filterPositionAttribute = glGetAttribLocation(filterProgram, "position");
    filterTextureCoordinateAttribute = glGetAttribLocation(filterProgram, "texcoord");
    filterInputTextureUniform = glGetUniformLocation(filterProgram, "inputImageTexture");
    
    GLint status;
    glGetProgramiv(filterProgram, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        NSLog(@"Failed to link program %d", filterProgram);
        goto exit;
    }
    result = validateProgram(filterProgram);
exit:
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        NSLog(@"OK setup GL programm");
    } else {
        glDeleteProgram(filterProgram);
        filterProgram = 0;
    }
    return result;
}

- (void) releaseRender;
{
    if (filterProgram) {
        glDeleteProgram(filterProgram);
        filterProgram = 0;
    }
}

- (void) setInputTexture:(GLint) textureId;
{
    _inputTexId = textureId;
}

- (GLint) outputTextureID
{
    return -1;
}

@end
