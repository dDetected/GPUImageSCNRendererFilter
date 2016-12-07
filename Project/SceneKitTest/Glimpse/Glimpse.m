//
//  Glimpse.m
//  Glimpse
//
//  Created by Wess Cope on 3/25/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "Glimpse.h"
#import <QuartzCore/QuartzCore.h>
#import "GlimpseAssetWriter.h"

@interface Glimpse()
{
    dispatch_queue_t        _queue;
    dispatch_source_t       _source;
}
@property (copy, nonatomic)     GlimpseCompletedCallback    callback;
@property (strong, nonatomic)   GlimpseAssetWriter          *writer;
@property (copy, nonatomic)     NSURL                       *fileOutput;
@property (strong, nonatomic)   SCNView                     *view;

- (UIImage *)imageFromView:(UIView *)view;
@end

@implementation Glimpse

- (id)init
{
    self = [super init];
    if (self)
    {
        self.writer = [[GlimpseAssetWriter alloc] init];
    }
    return self;
}

- (void)startRecordingView:(SCNView *)view onCompletion:(GlimpseCompletedCallback)block {
    
    self.view = view;
    self.callback   = block;
    self.writer.size = CGSizeMake(640, 1136);
    
    self.writer.startDate = [NSDate date];
    
    __weak typeof(self) weakSelf = self;
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_source, dispatch_time(DISPATCH_TIME_NOW, 0), 0.15 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_source, ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.writer writeFrameWithImage:[view.snapshot copy]];
        });
    });
    dispatch_resume(_source);
}

- (void)stop
{
    dispatch_source_cancel(_source);
    
    self.writer.endDate = [NSDate date];

    [self.writer writeVideoFromImageFrames:^(NSURL *outputPath) {
        self.callback(outputPath);
    }];
}

- (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size , YES , 0 );
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *rasterizedView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rasterizedView;
}

@end
