//
//  DMSceneView.h
//  SceneKitTest
//
//  Created by Антон Спивак on 07/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface DMSceneView : UIView

@property (strong, nonatomic) SCNScene *scene;

- (instancetype)initWithFrame:(CGRect)frame scene:(SCNScene *)scene context:(EAGLContext *)context;
- (void)renderFrame;

@end
