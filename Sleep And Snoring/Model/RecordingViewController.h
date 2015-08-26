//
//  FirstViewController.h
//  SnoreStreamer
//
//  Created by Guy Brown on 14/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioRecorder.h"
//#import "Model.h"
//#import "LogTableController.h"
//#import "SettingsViewController.h"
#import "SoundLevelMeterView.h"

@interface RecordingViewController : UIViewController

@property AudioRecorder *recorder;
@property IBOutlet UIButton *recordButton;
@property IBOutlet SoundLevelMeterView *meter;
@property (strong) NSTimer *meterTimer;
@property (weak) IBOutlet UILabel *timeElapsed;

-(IBAction)recordPressed:(id)sender;

@end

