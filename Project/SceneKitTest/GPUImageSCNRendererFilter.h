//
//  GPUImageSCNRendererFilter.h
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import <GPUImage/GPUImage.h>

extern NSString *const kGPUImageLuminanceFragmentShaderString;

@class SCNView;

@interface GPUImageSCNRendererFilter : GPUImageFilter

- (instancetype)initWithSceneView:(SCNScene *)_scene context:(EAGLContext *)_context;

@end
