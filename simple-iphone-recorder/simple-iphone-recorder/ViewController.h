//
//  ViewController.h
//  simple-iphone-recorder
//
//  Created by Edward anderson on 5/8/14.
//  Copyright (c) 2014 Edward anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController : UIViewController{
    AVAudioRecorder *recorder;
}


@end
