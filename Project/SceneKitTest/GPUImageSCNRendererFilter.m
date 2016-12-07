//
//  GPUImageSCNRendererFilter.m
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import "GPUImageSCNRendererFilter.h"
#import <SceneKit/SceneKit.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageLuminanceFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float luminance = dot(textureColor.rgb, W);
     
     gl_FragColor = vec4(vec3(luminance), textureColor.a);
 }
 );
#else
NSString *const kGPUImageLuminanceFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float luminance = dot(textureColor.rgb, W);
     
     gl_FragColor = vec4(vec3(luminance), textureColor.a);
 }
 );
#endif

@implementation GPUImageSCNRendererFilter {
    
    EAGLContext *context;
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLint width;
    GLint height;
    
    SCNRenderer *renderer;
    SCNScene *scene;
}

- (id)initWithSceneView:(SCNScene *)_scene context:(EAGLContext *)_context;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLuminanceFragmentShaderString]))
    {
        return nil;
    }
    scene = _scene;
    context = _context;
    [self prepareToRender];
    return self;
}

- (void)prepareToRender {
    [self initializeOpenGL];
    
    renderer = [SCNRenderer rendererWithContext:context options:nil];
    renderer.scene = scene;
}

- (BOOL)initializeOpenGL {
    
    //    context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: context];
//    
//    CAEAGLLayer *layer = (id)self.layer;
//    layer.contentsScale = [UIScreen mainScreen].scale;
//    layer.opaque = YES;
    
    glGenFramebuffers( 1, &framebuffer );
    glBindFramebuffer( GL_FRAMEBUFFER, framebuffer );
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
//    if (![context renderbufferStorage:GL_RENDERBUFFER fromDrawable: layer]) return NO;
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    GLuint depthRenderbuffer;
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    return glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [EAGLContext setCurrentContext: context];
    
    glBindFramebuffer( GL_FRAMEBUFFER, framebuffer );
    glBindRenderbuffer( GL_RENDERBUFFER, colorRenderbuffer );
    
    glViewport(0, 0, width, height );
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    [renderer render];
    
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

@end
