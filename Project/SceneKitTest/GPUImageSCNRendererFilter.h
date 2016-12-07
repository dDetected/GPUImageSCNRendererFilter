//
//  GPUImageSCNRendererFilter.h
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@class SCNScene, SCNRenderer;

@interface GPUImageSCNRendererFilter : GPUImageFilter

@property (strong, nonatomic) SCNRenderer *renderer;

- (instancetype)initWithScene:(SCNScene *)scene context:(EAGLContext *)context;

@end
