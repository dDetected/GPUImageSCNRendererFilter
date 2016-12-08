//
//  GPUImageSCNRendererFilter.m
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import "GPUImageSCNRendererFilter.h"
#import <SceneKit/SceneKit.h>

@implementation GPUImageSCNRendererFilter

- (id)initWithScene:(SCNScene *)scene {
    if (self == [super initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {
        _renderer = [SCNRenderer rendererWithContext:[GPUImageContext sharedImageProcessingContext].context options:nil];
        _renderer.scene = scene;
    }
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }
    
    [self.renderer render];
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
