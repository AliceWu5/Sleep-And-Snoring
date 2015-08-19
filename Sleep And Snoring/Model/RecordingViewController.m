//
//  FirstViewController.m
//  SnoreStreamer
//
//  Created by Guy Brown on 14/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "RecordingViewController.h"
//#import "SessionInfo.h"
#import "Model.h"
#import "Constants.h"
#import "SSKeychain.h"
//#import "ServerCommunicationController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface RecordingViewController ()

@end

@implementation RecordingViewController

-(void)viewDidAppear:(BOOL)animated
{
    [self updateLoginStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register for AV notification so we are told if sound recording is interrupted by call or Siri
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopRecordingDueToInterruption)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    // disable the tab bar
    
    //UITabBarItem *settingsItem = [self.tabBarController.tabBar.items objectAtIndex:TAB_BAR_INDEX];
    //[settingsItem setEnabled:NO];

    // Initialise the sound level meter
    [self.meter setup];
    
    // clear the elapsed time
    [self clearElapsedTime];
    
    // set up a session to make sure that we have access to the microphone
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session requestRecordPermission:^(BOOL granted) {}];
    
    // get a reference to the model since we will use it quite a bit
    Model *model = [Model sharedInstance];
    
    // check whether this device allows audio gain to be set
    model.gainChangeIsEnabled = session.inputGainSettable;
    if (session.inputGainSettable) {
        // enable audio gain controls
    } else {
        [model writeToLog:@"Cannot set audio gain for this device"];
    }
    
    // set the mode to disable automatic gain control and use the primary microphone
    NSError *error;
    [session setMode:AVAudioSessionModeMeasurement error:&error];
    if (error) {
        [model writeToLog:@"Cannot set audio measurement mode on this device"];
    }
    
    // if the username and password credentials are already in the keychain, retrieve them
    NSArray* accounts = [SSKeychain accountsForService:SERVICE_NAME];
    if ([accounts count] > 0)
    {
        id account = [accounts objectAtIndex:0];
        NSString* user = [account objectForKey:@"acct"];
        NSString* pass = [SSKeychain passwordForService:SERVICE_NAME account:user];
        if (pass)
        {
//            BOOL login = [ServerCommunicationController attemptLoginWithUser:user password:pass];
//            if (login) {
//                model.username = user;
//                model.currentlyLoggedIn = YES;
//                [model writeToLog:@"Logged in to server"];
//                SessionInfo *sessionInfo = [SessionInfo sharedInstance];
//                [model writeToLog:[sessionInfo.session description]];
//                [settingsItem setEnabled:sessionInfo.session.isAdmin];
//            } else {
//                [SSKeychain deletePasswordForService:SERVICE_NAME account:user];
//                model.username = @"";
//                model.currentlyLoggedIn = NO;
//                [model writeToLog:[ServerCommunicationController loginError]];
//            }
        }
    }
    [self updateLoginStatus];
    
    // get reference to the recording manager
    self.manager = [[RecordingManager alloc] init];
    
}

-(void)updateLoginStatus
{
    Model *model = [Model sharedInstance];
//    if (model.currentlyLoggedIn) {
//        self.networkStatus.text = [NSString stringWithFormat:@"Signed in as user %@",model.username];
//    } else {
//        self.networkStatus.text = @"Not signed in";
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(BOOL)isWifiConnected {
    Model *model = [Model sharedInstance];
    // check that we are connected via WiFi and not 3G
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    if (!success) {
        [model writeToLog:@"Error - unknown type of network connection"];
        return NO;
    }
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);
    CFRelease(reachability);
    if (!isNetworkReachable) {
        [model writeToLog:@"Error - no network connection"];
        return NO;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        [model writeToLog:@"Connected to 3G network"];
        return NO;
    } else {
        [model writeToLog:@"Connected to WiFi network"];
        return YES; // wifi connection
    }
}

-(IBAction)recordPressed:(id)sender
{
    // get reference to data model
    Model *model = [Model sharedInstance];
    NSMutableArray *errorStrings = [NSMutableArray arrayWithCapacity:5];
    // check that the user has given permission to record audio
    // if not, we can't proceed
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.recordPermission!=AVAudioSessionRecordPermissionGranted) {
        [errorStrings addObject:@"you have not given permission to record audio"];
    }
    // check that we are logged in
    if (model.currentlyLoggedIn==NO) {
        // we are not connected to the server, so can't proceed
        [errorStrings addObject:@"you are not signed in"];
    }
    if (model.safeMode) {
        // safe mode is on, so check that we are connected through WiFi (not 3G) and that
        // the power cable is plugged in
        if ([self isWifiConnected]==NO) {
            [errorStrings addObject:@"you are not connected to WiFi"];
        }
        if ([self isPowerConnected]==NO) {
            [errorStrings addObject:@"the power cable is not plugged in"];
        }
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
    if (model.isRecording) {
        // stop recording
        model.isRecording = NO;
        [self setRecordButtonOff];
        [self.manager stopRecording];
        [self.meterTimer invalidate];
        self.meterTimer=nil;
        self.meter.level=0.0;
        // return the screen to original brightness level
        [UIScreen mainScreen].brightness = model.brightness;
        // clear the elapsed time
        [self clearElapsedTime];
        // now switch to the demographics to collect and upload user information
        [self performSegueWithIdentifier:@"goDemographics" sender:self];
    } else {
        // just to be sure to remove any hangers-on, delete all files in the documents
        // directory from the last time this was run
        [self deleteAllAudioFiles];
        // clear the log so that we start with an empty table
        [model clearUploadTable];
        [model clearLog];
        // start recording
        BOOL ok = [self.manager startRecording];
        if (ok) {
            // set record button to red
            [self setRecordButtonOn];
            model.isRecording = YES;
            // start a timer to update the sound level meter at regular intervals
            self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSoundLevelMeter) userInfo:nil repeats:YES];
            // cache the brightness and dim the screen
            model.brightness = [UIScreen mainScreen].brightness;
            if ([model dimmingEnabled]) {
                [UIScreen mainScreen].brightness = DIMMED_BRIGHTNESS;
            }
            // log the current time as the time that recording started
            [Model sharedInstance].timeRecordingStarted = [NSDate date];
            // write to the log that we have started
            [[Model sharedInstance] writeToLog:@"Recording started"];
        } else {
            [[Model sharedInstance] writeToLog:@"ERROR: you are not signed in to the server"];
        }
    }
}

-(void)setRecordButtonOff
// turn the record button back to its normal color
{
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0]];
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0]];
}

-(void)setRecordButtonOn
// make the record button red
{
    [self.recordButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0]];
}

-(void)stopRecordingDueToInterruption
{
    Model *model = [Model sharedInstance];
    model.isRecording = NO;
    [self setRecordButtonOff];
    [self.manager stopRecording];
    [self.meterTimer invalidate];
    self.meterTimer=nil;
    self.meter.level=0.0;
    // return the screen to original brightness level
    [UIScreen mainScreen].brightness = model.brightness;
    // clear the elapsed time
    [self clearElapsedTime];
    // write a message to the log
    [model writeToLog:@"Recording was interrupted by call or Siri"];
    // now switch to the demographics to collect and upload user information
    [self performSegueWithIdentifier:@"goDemographics" sender:self];
}

-(void)clearElapsedTime
{
    self.timeElapsed.text = @"Recording time so far: 00h:00m:00s";
}

-(void)updateSoundLevelMeter
{
    self.meter.level = [self.manager getNormalisedSoundLevel];
    // also update the time since now text - really this should be in a separate method
    NSTimeInterval timeDiff = [[Model sharedInstance].timeRecordingStarted timeIntervalSinceNow];
    int ti = -(int)timeDiff;
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
        BOOL ok = [fm removeItemAtPath:filePath error:&error];
        if (!ok) {
            [[Model sharedInstance] writeToLog:[NSString stringWithFormat:@"Error in deleteAllAudioFiles: could not delete file %@",filePath]];
        }
    }
}

@end
