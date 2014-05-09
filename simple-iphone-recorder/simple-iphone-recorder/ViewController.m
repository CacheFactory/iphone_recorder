//
//  ViewController.m
//  simple-iphone-recorder
//
//  Created by Edward anderson on 5/8/14.
//  Copyright (c) 2014 Edward anderson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

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
                              [NSNumber numberWithInt:kAudioFormatMPEGLayer3],     AVFormatIDKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.mp4"];

    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    recorder.meteringEnabled = YES;
    self.statusLabel.text = @"Waiting for to start recording";
	self.submitButton.hidden=YES;
}
- (IBAction)submitButtonPressed:(id)sender {
    
}
- (IBAction)recordAudio:(id)sender {
    if(recorder.recording){
        [recorder prepareToRecord];
  		[recorder record];
        self.statusLabel.text = @"Recording";
    }else{
        [recorder stop];
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        self.statusLabel.text = @"Recording stopped";
        self.submitButton.hidden=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
