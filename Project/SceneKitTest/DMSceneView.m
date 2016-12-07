//
//  DMSceneView.m
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import "DMSceneView.h"

@implementation DMSceneView {
    
    EAGLContext *context;
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLint width;
    GLint height;
    
    SCNRenderer *renderer;
}

- (instancetype)initWithFrame:(CGRect)frame scene:(SCNScene *)scene context:(EAGLContext *)_context {
    if (self == [super initWithFrame:frame]) {
        _scene = scene;
        context = _context;
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (BOOL)initializeOpenGL {
    
//    context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: context];
    
    CAEAGLLayer *layer = (id)self.layer;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.opaque = YES;
    
    glGenFramebuffers( 1, &framebuffer );
    glBindFramebuffer( GL_FRAMEBUFFER, framebuffer );
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    if (![context renderbufferStorage:GL_RENDERBUFFER fromDrawable: layer]) return NO;
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

- (void)prepareToRender {
    [self initializeOpenGL];
    
    renderer = [SCNRenderer rendererWithContext:context options:nil];
    renderer.scene = self.scene;
}

- (void)renderFrame {
    if (!context) {
        [self prepareToRender];
    }
    
    [EAGLContext setCurrentContext: context];
    
    glBindFramebuffer( GL_FRAMEBUFFER, framebuffer );
    glBindRenderbuffer( GL_RENDERBUFFER, colorRenderbuffer );
    
    glViewport(0, 0, width, height );
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    [renderer render];
    
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
