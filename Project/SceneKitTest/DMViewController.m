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

@interface DMViewController () <SCNSceneRendererDelegate, GPUImageVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet GPUImageView *cameraView;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) GPUImageAlphaBlendFilter *blender;
@property (strong, nonatomic) GPUImageUIElement *element;

@property (strong, nonatomic) NSURL *cameraVideoOuputURL;

@property (strong, nonatomic) UIImageView *fake;

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    self.camera.delegate = self;
    
    self.sceneView.scene = [SCNScene sceneNamed:@"Objects.scnassets/main.scn"];
    self.sceneView.allowsCameraControl = NO;
    self.sceneView.showsStatistics = YES;
    self.sceneView.backgroundColor = [UIColor clearColor];
    self.sceneView.delegate = self;
    
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    [self.camera addTarget:filter];
    
    self.blender = [[GPUImageAlphaBlendFilter alloc] init];
    self.blender.mix = 1;
    self.element = [[GPUImageUIElement alloc] initWithView:self.fake];
    
    [filter addTarget:self.blender];
    [self.element addTarget:self.blender];
    [self.blender addTarget:self.cameraView];
    
    __weak typeof(self) welf = self;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *input, CMTime time) {
        UIImageView *v = self.fake;
        [welf.element setValue:v forKey:@"view"];
        [welf.element setValue:v.layer forKey:@"layer"];
        [welf.element update];
    }];
    
    
    SCNNode *n = [self.sceneView.scene.rootNode childNodeWithName:@"coin" recursively:YES];
    [n runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:10 z:0 duration:0.3]]];
    
    UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:self.view.gestureRecognizers];
    self.view.gestureRecognizers = gestureRecognizers;
}

- (UIImageView *)fake {
    return [[UIImageView alloc] initWithImage:self.sceneView.snapshot];
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

}

- (void)stopRecording {

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
