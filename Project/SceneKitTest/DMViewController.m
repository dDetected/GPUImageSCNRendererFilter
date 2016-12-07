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
#import "GPUImageSCNRendererFilter.h"

@interface DMViewController () <GPUImageVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet GPUImageView *cameraView;

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) GPUImageSCNRendererFilter *filter;
@property (strong, nonatomic) GPUImageMovieWriter *writer;
@property (strong, nonatomic) SCNScene *scene;

@property (strong, nonatomic) NSURL *cameraVideoOuputURL;

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    self.camera.delegate = self;
    
    self.scene = [SCNScene sceneNamed:@"Objects.scnassets/main.scn"];
    self.filter = [[GPUImageSCNRendererFilter alloc] initWithScene:self.scene context:[GPUImageContext sharedImageProcessingContext].context];
    [self.camera addTarget:self.filter];
    [self.filter addTarget:self.cameraView];
    
    self.writer = [[GPUImageMovieWriter alloc] initWithMovieURL:self.cameraVideoOuputURL size:self.view.bounds.size];
    self.writer.encodingLiveVideo = true;
    [self.filter addTarget:self.writer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    NSMutableArray *gestures = [NSMutableArray array];
    [gestures addObject:pan];
    [gestures addObjectsFromArray:self.view.gestureRecognizers];
    self.view.gestureRecognizers = gestures;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestCameraAccess:^{
        [self startCapture];
    }];
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
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager removeItemAtPath:self.cameraVideoOuputURL.absoluteString error:&error];
    
    [self.writer startRecording];
}

- (void)stopRecording {
    __weak typeof(self) welf = self;
    [self.writer finishRecordingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf requestLibraryAccess:^{
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:self.cameraVideoOuputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    NSLog(@"AHTUUUUUUNG!!!!!");
                }];
            }];
        });
    }];
}


#pragma mark - Actions 

- (IBAction)startButtonDidClick:(UIButton *)sender {
    [self startRecording];
}

- (IBAction)stopButtonDidClick:(UIButton *)sender {
    [self stopRecording];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    SCNNode *node = [self.scene.rootNode childNodeWithName:@"coin" recursively:YES];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [node.physicsBody applyTorque:SCNVector4Make(0, -node.physicsBody.angularVelocity.y, 0, -node.physicsBody.angularVelocity.w) impulse:YES];
    } else {
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        CGFloat angle = translation.x * (M_PI)/180.0;
        
        [node.physicsBody applyTorque:SCNVector4Make(0, 10000, 0, angle) impulse:YES];
    }
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
