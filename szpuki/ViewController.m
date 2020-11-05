//
//  ViewController.m
//  szpuki
//
//  Created by Akos Toth-Mate on 2020. 10. 31..
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) AVAudioSession *audioSession;
@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) CMMotionManager *motionManager;

@property (nonatomic) UIButton *button1;
@property (nonatomic) UIButton *button2;
@property (nonatomic) UIButton *button3;
@property (nonatomic) UIButton *button4;

@property int extremeRotationCounter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.button1 = [[UIButton alloc] init];
    self.button1.frame = CGRectMake(80.0, 30.0, 160.0, 40.0);
    self.button1.backgroundColor = UIColor.lightGrayColor;
    
    self.button2 = [[UIButton alloc] init];
    self.button2.frame = CGRectMake(80.0, 80.0, 160.0, 40.0);
    self.button2.backgroundColor = UIColor.lightGrayColor;
    
    self.button3 = [[UIButton alloc] init];
    self.button3.frame = CGRectMake(80.0, 130.0, 160.0, 40.0);
    self.button3.backgroundColor = UIColor.lightGrayColor;
    
    self.button4 = [[UIButton alloc] init];
    self.button4.frame = CGRectMake(80.0, 180.0, 160.0, 40.0);
    self.button4.backgroundColor = UIColor.lightGrayColor;
        
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [[self view] addGestureRecognizer:singleFingerTap];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    self.audioSession = [AVAudioSession sharedInstance];
    
    [self.audioSession requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSDictionary *settings = @{
                AVFormatIDKey : @(kAudioFormatAppleLossless),
                AVSampleRateKey : @44100.0,
                AVNumberOfChannelsKey : @1
            };
            
            self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:@"/dev/null"] settings:settings error:nil];
            [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            self.recorder.meteringEnabled = YES;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateScreen) userInfo:nil repeats:YES];
            [self.recorder record];
        }
    }];
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startGyroUpdates];
}

- (void)updateScreen {
    [self.recorder updateMeters];
    float db = [self.recorder averagePowerForChannel:0];
    
    CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration;
    double maxAcceleration = MAX(ABS(acceleration.x), MAX(ABS(acceleration.y), ABS(acceleration.z)));
    
    CMRotationRate rotation = self.motionManager.gyroData.rotationRate;
    double maxRotation = MAX(ABS(rotation.x), MAX(ABS(rotation.y), ABS(rotation.z)));
    
    CGFloat hue = (arc4random() % 36 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = MIN(1.0, MAX(0.0, (db + 55.0) / 35.0));
    
    if (maxRotation > 0.2) {
        self.extremeRotationCounter = 40;
    }
    
    if (self.extremeRotationCounter > 0) {
        brightness = 1.0;
        self.extremeRotationCounter -= 1;
    }
    
    if (brightness < 0.1) {
        [[UIScreen mainScreen] setBrightness:0];
    } else {
        [[UIScreen mainScreen] setBrightness:1.0];
    }
    
    self.view.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    [self.button1 setTitle:[NSString stringWithFormat:@"db: %.5f", db] forState:UIControlStateNormal];
    [self.button2 setTitle:[NSString stringWithFormat:@"bri: %.5f", brightness] forState:UIControlStateNormal];
    [self.button3 setTitle:[NSString stringWithFormat:@"acc: %.5f", maxAcceleration] forState:UIControlStateNormal];
    [self.button4 setTitle:[NSString stringWithFormat:@"rot: %.5f", maxRotation] forState:UIControlStateNormal];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.button1.superview == nil) {
        [self.view addSubview:self.button1];
        [self.view addSubview:self.button2];
        [self.view addSubview:self.button3];
        [self.view addSubview:self.button4];
    } else {
        [self.button1 removeFromSuperview];
        [self.button2 removeFromSuperview];
        [self.button3 removeFromSuperview];
        [self.button4 removeFromSuperview];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
