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

- (id)initWithScene:(SCNScene *)scene context:(EAGLContext *)context {
    if (self == [super initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {
        _renderer = [SCNRenderer rendererWithContext:context options:nil];
        _renderer.scene = scene;
    }
    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self.renderer render];
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

@end
