//
//  FirstViewController.m
//  SnoreStreamer
//
//  Created by Guy Brown on 14/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "RecordingViewController.h"
#import "AudioRecorder.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface RecordingViewController ()

@end

@implementation RecordingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register for AV notification so we are told if sound recording is interrupted by call or Siri
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopRecordingDueToInterruption)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    // Initialise the sound level meter
    [self.meter setup];
    
    // clear the elapsed time
    [self clearElapsedTime];
    
    // set up audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [session setInputGain:1.0f error:nil];
    [session requestRecordPermission:^(BOOL granted) {}];
    [session setActive:YES error:nil];
    
    if (session.inputGainSettable) {
        // enable audio gain controls
    } else {
        
    }
    
    // get reference to the recording manager
    self.recorder = [[AudioRecorder alloc] init];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    // keep in portrait mode
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)isPowerConnected {
    // if we are running in the simulator, power connection is not an issue
    if (TARGET_IPHONE_SIMULATOR)
        return YES;
    // otherwise, check that we are plugged in
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    return (currentState==UIDeviceBatteryStateCharging || currentState==UIDeviceBatteryStateFull);
}

//-(BOOL)isWifiConnected {
//    // check that we are connected via WiFi and not 3G
//    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
//    SCNetworkReachabilityFlags flags;
//    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
//    if (!success) {
//        [model writeToLog:@"Error - unknown type of network connection"];
//        return NO;
//    }
//    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
//    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
//    BOOL isNetworkReachable = (isReachable && !needsConnection);
//    CFRelease(reachability);
//    if (!isNetworkReachable) {
//        [model writeToLog:@"Error - no network connection"];
//        return NO;
//    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
//        [model writeToLog:@"Connected to 3G network"];
//        return NO;
//    } else {
//        [model writeToLog:@"Connected to WiFi network"];
//        return YES; // wifi connection
//    }
//}

-(IBAction)recordPressed:(id)sender
{
    NSMutableArray *errorStrings = [NSMutableArray arrayWithCapacity:5];
    // check that the user has given permission to record audio
    // if not, we can't proceed
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.recordPermission!=AVAudioSessionRecordPermissionGranted) {
        [errorStrings addObject:@"you have not given permission to record audio"];
    }

    // check if the power cable is plugged in
    if ([self isPowerConnected]==NO && !self.recorder.isRecording) {
        [errorStrings addObject:@"the power cable is not plugged in"];
    }
    
    // if there is a problem, go no further
    NSUInteger numErrors = [errorStrings count];
    if (numErrors>0) {
        NSString *errorStr = @"";
        if (numErrors==1)
            errorStr = (NSString*)(errorStrings[0]);
        else if (numErrors==2)
            errorStr = [NSString stringWithFormat:@"%@ and %@",errorStrings[0],errorStrings[1]];
        else if (numErrors==3)
            errorStr = [NSString stringWithFormat:@"%@, %@ and %@",errorStrings[0],errorStrings[1],errorStrings[2]];
        // return the (capitalised) string in an alert box. The little touches are so important.
        NSString *capStr = [NSString stringWithFormat:@"%@%@",[[errorStr substringToIndex:1] uppercaseString],[errorStr substringFromIndex:1]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:capStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    // otherwise ...
    if (self.recorder.isRecording) {
        // stop recording
        [self setRecordButtonOff];
        [self.recorder stopRecording];
        [self.meterTimer invalidate];
        self.meterTimer=nil;
        self.meter.level=0.0;
        // clear the elapsed time
        [self clearElapsedTime];
    } else {
        // start recording
        BOOL ok = [self.recorder startRecording];
        if (ok) {
            NSLog(@"Is recording");
            // set record button to red
            [self setRecordButtonOn];
            // start a timer to update the sound level meter at regular intervals
            self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSoundLevelMeter) userInfo:nil repeats:YES];
        } else {
            // send out notification
            NSLog(@"Unable to record");
        }
    }
}

-(void)setRecordButtonOff
// turn the record button back to its normal color
{
    self.recordButton.titleLabel.text = @"Record";
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0]];
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0]];
}

-(void)setRecordButtonOn
// make the record button red
{
    self.recordButton.titleLabel.text = @"Recording";
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0]];
}

-(void)stopRecordingDueToInterruption
{
    self.recorder.isRecording = NO;
    [self setRecordButtonOff];
    [self.recorder stopRecording];
    [self.meterTimer invalidate];
    self.meterTimer=nil;
    self.meter.level=0.0;
    // clear the elapsed time
    [self clearElapsedTime];
}

-(void)clearElapsedTime
{
    self.timeElapsed.text = @"Recording time so far: 00h:00m:00s";
}

-(void)updateSoundLevelMeter
{
    self.meter.level = [self.recorder getSoundLevel];
    // also update the time since now text - really this should be in a separate method
    NSTimeInterval timeDiff = [self.recorder getRecordingTime];
    int ti = (int)timeDiff;
    int seconds = ti % 60;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600);
    self.timeElapsed.text = [NSString stringWithFormat:@"Recording time so far: %02dh:%02dm:%02ds",hours,minutes,seconds];
}

-(void)deleteAllAudioFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docPaths objectAtIndex:0];
    NSArray *filelist= [fm contentsOfDirectoryAtPath:path error:nil];
    NSError *error;
    // remove all files in the documents directory
    for (NSString* filename in filelist)
    {
        // get path to file
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        // remove it
        [fm removeItemAtPath:filePath error:&error];
        // might need code when unable to delete file
    }
}

@end
