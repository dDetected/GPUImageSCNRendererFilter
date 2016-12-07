//
//  Glimpse.h
//  Glimpse
//
//  Created by Wess Cope on 3/25/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <UIKit/UIKit.h>

/**
 `Glimpse` is a class that allows recording of UIViews and their interactions and animations.
 */

/**
 Callback block that is called when a recording session is complete.
 **/
typedef void(^GlimpseCompletedCallback)(NSURL *fileOuputURL);

@interface Glimpse : NSObject

- (void)startRecordingView:(SCNView *)view onCompletion:(GlimpseCompletedCallback)block;
- (void)stop;

@end
