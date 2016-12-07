//
//  GPUImageSCNRendererFilter.h
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@class SCNView;

@interface GPUImageSCNRendererFilter : GPUImageFilter

@property (strong, nonatomic) SCNView *sceneView;

- (instancetype)initWithSceneView:(SCNView *)sceneView;

@end
