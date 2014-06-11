//
//  ViewController.m
//  simple-iphone-recorder
//
//  Created by Edward anderson on 5/8/14.
//  Copyright (c) 2014 Edward anderson. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIProgressView *recordingLevelBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error = nil;
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];

    soundUrl= [NSURL fileURLWithPath:soundFilePath];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *audioSessionError;
    
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
    [audioSession setActive:YES error:&audioSessionError];
    
    
    
    recorder = [[AVAudioRecorder alloc] initWithURL:soundUrl settings:settings error:&error];
    recorder.meteringEnabled = YES;
    
    
    
    self.statusLabel.text = @"Waiting to start recording";
	self.submitButton.hidden=YES;
    
    NSOperationQueue *queue             = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation    = [[NSInvocationOperation alloc]
                                           initWithTarget:self selector:@selector(updateMeters) object:nil];
    [queue addOperation: operation];
    
}
- (IBAction)submitButtonPressed:(id)sender {
    NSDictionary *params = @{@"client_email(1-Form)": self.emailAddressField.text};
    NSData *data = [NSData dataWithContentsOfURL:soundUrl];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:@"https://sterett.Taskflow.io/public_interactions/start_public/288" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"dictation_file(1-Form)" fileName:@"recording.caf" mimeType:@"audio/x-caf"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //hack
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(error.code == -1016){ //error if response back with html
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You will reveive and email with your dictation soon" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
            [alert show];
            [currentResponder resignFirstResponder];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error submitting your audio" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
            [alert show];
        }
        
    }];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}


- (IBAction)playButtonPressed:(id)sender {
    if(audioPlayer && !audioPlayer.isPlaying){
        
        [audioPlayer prepareToPlay];
        [audioPlayer play];
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];

    }else{
        [audioPlayer stop];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
}
- (IBAction)recordAudio:(id)sender {
    if(!recorder.recording){
        [audioPlayer stop];
        [recorder deleteRecording];
        [recorder prepareToRecord];
  		[recorder record];
        self.statusLabel.text = @"Recording";
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        self.submitButton.hidden=YES;
        self.slider.hidden=YES;
        self.playButton.hidden=YES;
        self.recordingLevelBar.hidden=NO;
        self.timeLabel.hidden =YES;
        self.emailAddressField.hidden=YES;
        
    }else{
        [recorder stop];
        self.statusLabel.text = @"Recording stopped";
        [self.recordButton setTitle:@"Start new recording" forState:UIControlStateNormal];
        self.submitButton.hidden=NO;
        self.slider.hidden=NO;
        self.playButton.hidden=NO;
        self.recordingLevelBar.hidden=YES;
        self.timeLabel.hidden =NO;
        
        NSError *audioSessionError;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&audioSessionError];
        audioPlayer.delegate = self;
        
        self.timeLabel.text = [NSString stringWithFormat:@"%.f seconds",audioPlayer.duration];
        self.emailAddressField.hidden=NO;
    }
}
- (IBAction)screenTap:(id)sender {
    [currentResponder resignFirstResponder];
}
- (IBAction)emailEditBegin:(id)sender {
    currentResponder = (UIInputView *)sender;
}

-(void)updateMeters
{
    
    do {
        [recorder updateMeters];
        
        
        if (recorder.recording) {
            averagePower   = [recorder averagePowerForChannel:0];
            peakPower      = [recorder peakPowerForChannel:0];
            [self performSelectorOnMainThread:
             @selector(meterLevelsDidUpdate:) withObject:self waitUntilDone:NO];
        }
        /*
        if(audioPlayer.playing){
            [self performSelectorOnMainThread:
             @selector(playbackPostionUpdate:) withObject:self waitUntilDone:NO];
        }
        */
        [NSThread sleepForTimeInterval:.05]; // 20 FPS
    } while (YES);
}

-(void)meterLevelsDidUpdate:(id)sender{
    [self.recordingLevelBar setProgress: pow (10, peakPower / 20) animated:NO];

}
/*
-(void)playbackPostionUpdate:(id)sender{
    NSTimeInterval durration = audioPlayer.duration;
    NSTimeInterval position = audioPlayer.deviceCurrentTime;

    [self.slider setValue:(durration-position)/durration animated:NO];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
