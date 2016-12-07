//
//  GameViewController.m
//  SceneKitTest
//
//  Created by Антон Спивак on 05/12/2016.
//  Copyright © 2016 Anton Spivak. All rights reserved.
//

#import "DMViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ReplayKit/ReplayKit.h>
#import "Glimpse.h"

@interface DMViewController () <SCNSceneRendererDelegate, GPUImageVideoCameraDelegate> {
    
    NSTimeInterval rendererDidRenderSceneTimeLast;
    NSTimeInterval recorderDidAddSceneToVideoTimeLast;
    
    dispatch_queue_t    _queue;
    dispatch_source_t   _source;
    
    BOOL isRecording;
    BOOL isRecordingFirstFrame;
}

@property (weak, nonatomic) IBOutlet GPUImageView *fakeCameraView;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@property (strong, nonatomic) AVAssetWriter *writer;
@property (strong, nonatomic) AVAssetWriterInput *input;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *adapter;

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) NSURL *cameraVideoOuputURL;

@property (strong, nonatomic) NSMutableArray *frames;

@property (strong, nonatomic) Glimpse *gl;

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    self.camera.delegate = self;
    
    [self.camera addTarget:self.fakeCameraView];
    
    SCNScene *scene = [SCNScene sceneNamed:@"Objects.scnassets/main.scn"];
    scene.background.contents = self.fakeCameraView.layer;
    
    self.sceneView.scene = scene;
    self.sceneView.allowsCameraControl = NO;
    self.sceneView.showsStatistics = YES;
    self.sceneView.backgroundColor = [UIColor greenColor];
    self.sceneView.delegate = self;
    
    UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:self.view.gestureRecognizers];
    self.view.gestureRecognizers = gestureRecognizers;
    
    rendererDidRenderSceneTimeLast = 0;
    recorderDidAddSceneToVideoTimeLast = 0;
    isRecording = NO;
    isRecordingFirstFrame = YES;
    
    self.gl = [[Glimpse alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestCameraAccess:^{
        [self startCapture];
    }];
}

- (void)initWriter {
    
    self.writer = [[AVAssetWriter alloc] initWithURL:self.cameraVideoOuputURL
                                            fileType:AVFileTypeMPEG4
                                               error:nil];
    
    
    NSDictionary *settings = @{AVVideoCodecKey : AVVideoCodecH264,
                               AVVideoWidthKey : @(640),
                               AVVideoHeightKey : @(1136)};
    
    
    self.input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    
    NSDictionary *attributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB),
                                 (NSString *)kCVPixelBufferWidthKey : @(640),
                                 (NSString *)kCVPixelBufferHeightKey: @(1136)};
    
    
    self.adapter = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.input
                                                                                    sourcePixelBufferAttributes:attributes];
    
    self.input.expectsMediaDataInRealTime = YES;
    [self.writer addInput:self.input];
    
    [self.writer startWriting];
    [self.writer startSessionAtSourceTime:kCMTimeZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Session

- (void)startCapture {
    [self.camera resumeCameraCapture];
    [self.camera startCameraCapture];
}

- (void)stopCapture {
    [self.camera pauseCameraCapture];
    [self.camera stopCameraCapture];
    runSynchronouslyOnVideoProcessingQueue(^{
        glFinish();
    });
}

- (void)startRecording {
//    [self.gl startRecordingView:self.sceneView onCompletion:^(NSURL *fileOuputURL) {
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library writeVideoAtPathToSavedPhotosAlbum:fileOuputURL completionBlock:^(NSURL *assetURL, NSError *error){
//            NSLog(@"AHTUUUUUUNG!!!!!");
//        }];
//    }];
    
    
//    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
//        NSLog(@"");
//    }];
    
    
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cameraVideoOuputURL.absoluteString]) {
//        [[NSFileManager defaultManager] removeItemAtPath:self.cameraVideoOuputURL.absoluteString error:nil];
//    }
//    isRecording = YES;
    
    
    
    
    
    
    //    __weak typeof(self) welf = self;
    //    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    //    dispatch_source_set_timer(_source, dispatch_time(DISPATCH_TIME_NOW, 0), 0.03 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //    dispatch_source_set_event_handler(_source, ^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            static NSUInteger count = 0;
    //
    //            if (isRecordingFirstFrame) {
    //                isRecordingFirstFrame = NO;
    //                [welf initWriter];
    //                count = 0;
    //            }
    //
    //            CVPixelBufferRef buffer = [welf pixelBufferForImage:welf.sceneView.snapshot];
    //
    //            CMTime present = CMTimeMake(count, 30);
    //            if (self.input.readyForMoreMediaData) {
    //                [self.adapter appendPixelBuffer:buffer withPresentationTime:present];
    //            }
    //
    //            CVPixelBufferRelease(buffer);
    //        });
    //    });
    //    dispatch_resume(_source);
}

- (void)stopRecording {
//    [self.gl stop];
    
    
    
    
//    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
//        [self presentViewController:previewViewController animated:YES completion:nil];
//    }];
    
    
    
    
//    if (!isRecording) {
//        NSLog(@"Record was stopped");
//        return;
//    }
//    isRecording = NO;
//    isRecordingFirstFrame = YES;
//    [self.input markAsFinished];
//    [self requestLibraryAccess:^{
//        [self.writer finishWritingWithCompletionHandler:^{
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeVideoAtPathToSavedPhotosAlbum:self.cameraVideoOuputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                NSLog(@"AHTUUUUUUNG!!!!!");
//            }];
//        }];
//    }];
    
    
    
    
    
//    dispatch_source_cancel(_source);
}


#pragma mark - Actions 

- (IBAction)startButtonDidClick:(UIButton *)sender {
    [self startRecording];
}

- (IBAction)stopButtonDidClick:(UIButton *)sender {
    [self stopRecording];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.sceneView];
    NSArray *results = [self.sceneView hitTest:point options:nil];
    
    if (results.count > 0) {
        SCNHitTestResult *result = [results objectAtIndex:0];
        SCNNode *node = result.node;
        if ([node.name isEqualToString:@"coin"]) {
            if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
                [node.physicsBody applyTorque:SCNVector4Make(0, -node.physicsBody.angularVelocity.y, 0, -node.physicsBody.angularVelocity.w) impulse:YES];
            } else {
                CGPoint translation = [gestureRecognizer translationInView:self.view];
                CGFloat angle = translation.x * (M_PI)/180.0;
                
                [node.physicsBody applyTorque:SCNVector4Make(0, 10000, 0, angle) impulse:YES];
            }
        }
    }
}

#pragma mark - SCNSceneRendererDelegate

- (void)renderer:(id<SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    
    NSTimeInterval timeSinceLast = time - rendererDidRenderSceneTimeLast;
    if (timeSinceLast > 1.0f/30.0f) {
        rendererDidRenderSceneTimeLast = 0;
        
        if (isRecording) {
            static NSUInteger count = 0;
            
            if (isRecordingFirstFrame) {
                isRecordingFirstFrame = NO;
                [self initWriter];
                count = 0;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *snapshot = self.sceneView.snapshot;
                CVPixelBufferRef buffer = [self pixelBufferForImage:snapshot];
    
                CMTime present = CMTimeMake(count, 30);
                if (self.input.readyForMoreMediaData) {
                    BOOL status = [self.adapter appendPixelBuffer:buffer withPresentationTime:present];
                }
    
                CVPixelBufferRelease(buffer);
            });
        }
    }
    rendererDidRenderSceneTimeLast = time;
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {

}

#pragma mark - Setters & Getters 

- (NSURL *)cameraVideoOuputURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"video_ouput.mp4"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - Helpers

- (CVPixelBufferRef)pixelBufferForImage:(UIImage *)image
{
    CGImageRef cgImage = image.CGImage;
    
    NSDictionary *options = @{
                              (NSString *)kCVPixelBufferCGImageCompatibilityKey: @(YES),
                              (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)
                              };
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &buffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    void *data                  = CVPixelBufferGetBaseAddress(buffer);
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef context        = CGBitmapContextCreate(data, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), 8, 4 * CGImageGetWidth(cgImage), colorSpace, (kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipFirst));
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return buffer;
}

- (void)requestCameraAccess:(void(^)(void))block {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                block();
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        block();
    }
}

- (void)requestLibraryAccess:(void(^)(void))block {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                block();
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        block();
    }
}

@end
