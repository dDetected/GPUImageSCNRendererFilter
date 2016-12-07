//
//  GPUImageSCNRendererFilter.m
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import "GPUImageSCNRendererFilter.h"

NSString *const kGPUSCNRendererFragmentShaderString = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
 
    void main() {
     
     
    }
);

@implementation GPUImageSCNRendererFilter

- (instancetype)initWithSceneView:(SCNView *)sceneView {
    if (self == [super initWithFragmentShaderFromString:kGPUSCNRendererFragmentShaderString]) {
        self.sceneView = sceneView;
    }
    return self;
}

@end
