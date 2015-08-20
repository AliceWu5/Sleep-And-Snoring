//
//  ViewController.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/13.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "SleepSnoringViewController.h"
#import "SleepScatterPlotController.h"
#import "OAuth2ViewController.h"
#import "APIFetcher.h"
#import "FitbitSleep.h"
#import "FitbitUser.h"
#import "FitbitActivity.h"
#import "FitbitHeartRate.h"
#import "Sleep2DLandscapeView.h"
#import "GenericDate.h"
#import "SSKeychain.h"

static NSString *const kSleepAndSnoringService          = @"Sleep And Snoring";
static NSString *const kSleepAndSnoringAccessAccount    = @"com.sleepandsnoring.accesstoken";
static NSString *const kSleepAndSnoringRefreshAccount   = @"com.sleepandsnoring.refreshtoken";

@interface SleepSnoringViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *sleepSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *heartRateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *audioSwitch;


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic)APIFetcher *fetcher;
@property (strong, nonatomic)FitbitHeartRate *heartRate;
@property (strong, nonatomic)FitbitUser *user;
@property (strong, nonatomic)FitbitSleep *sleep;
@property (strong, nonatomic)FitbitActivity *activity;


@property BOOL isSignedIn;
@end

@implementation SleepSnoringViewController
@synthesize isSignedIn = _isSignedIn;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.indicator.hidesWhenStopped = YES;
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initNavigationBarItems];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self checkLoginDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBarItems {
    
    self.navigationItem.title = @"Fitbit Data";
}

- (void)logInfo {
    NSLog(@"Button Pressed.");
}

- (void)checkLoginDetail {
    
    // get access token & refresh token from keychain
    NSString *accessToken = [SSKeychain passwordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    NSString *refreshToken = [SSKeychain passwordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
    
    // if credentials exist then do not need to sign in
    if (accessToken && refreshToken) {
        
        // create a fetcher
        NSLog(@"User credentials exist.");
        self.isSignedIn = YES;
        
        APIFetcher *fetcher = [APIFetcher fetcherWithOAuth2:[OAuth2ViewController customAuth] accessToken:accessToken refreshToken:refreshToken];
        self.fetcher = fetcher;
        
    } else {
        NSLog(@"Need to log in.");
        self.isSignedIn = NO;
    }
}

- (IBAction)startSignIn:(UIButton *)sender {
    OAuth2ViewController *authViewController = [[OAuth2ViewController alloc] init];
    authViewController.delegate = self;
    // manually sign out
    //[authViewController signOut];
    [[self navigationController] pushViewController:authViewController animated:YES];
}

- (IBAction)startSignOut:(UIButton *)sender {
    // user sign out
    [self sendAlterMessage:@"You have signed out"];
    
    // delete keychains
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
}

- (IBAction)plotSelectedData:(UIButton *)sender {
    
    if (self.isSignedIn) {
        BOOL hrSwitch = self.heartRateSwitch.on;
        BOOL sleepSwitch = self.sleepSwitch.on;
        BOOL audioSwitch = self.audioSwitch.on;
        
        if (hrSwitch && sleepSwitch && audioSwitch) {
            [self getSleepAndData];
        } else if (hrSwitch && sleepSwitch) {
            
        } else if (hrSwitch && audioSwitch) {
            
        } else if (sleepSwitch && audioSwitch) {
            
        }

    } else {
        [self sendAlterMessage:@"Please Sign in"];
    }
    
    
}

- (void)syncData:(UIButton *)sender {
    NSLog(@"Synchronize data from Fitbit.");
    if (self.isSignedIn) {
        [self.indicator startAnimating];
        
        [self.user updateUserProfile];
        [self.activity updateRecentActivities];
        [self.sleep updateSleepByDate:[NSDate date] completion:^(NSArray *sleepData) {
            [self.indicator stopAnimating];
            NSLog(@"should stop animating");
        }];
    } else {
        // to do
        [self sendAlterMessage:@"Please Sign in"];
    }
}

- (void)addItems:(id)item withMessage:(NSString *)message {
    NSLog(@"The message sent : %@", item);
    if ([item isKindOfClass:[APIFetcher class]]) {
        self.fetcher = item;
        self.isSignedIn = true;
        
        // set keychains when user credentials created
        [SSKeychain setPassword:self.fetcher.accessToken forService:kSleepAndSnoringService
                        account:kSleepAndSnoringAccessAccount];
        [SSKeychain setPassword:self.fetcher.refreshToken forService:kSleepAndSnoringService
                        account:kSleepAndSnoringRefreshAccount];
        // send alter message only when user have log in action
        [self sendAlterMessage:@"Sucessful!"];

    } else {
        [self sendAlterMessage:message];
    }
}

#pragma mark Fitbit API Methods


- (void)getSleepAndData {
    
    if (self.isSignedIn) {
        // get selected date sleep data
        NSDate *pickedDate = self.datePicker.date;
        [self.sleep getSleepByDate:pickedDate completion:^(NSArray *sleepData) {
            NSLog(@"GET SLEEP SUCCESSFULLY.");
            
            // init plot
            SleepScatterPlotController *plotController = [[SleepScatterPlotController alloc] init];
            
            // get selected date heart rate data
            [self.heartRate updateHeartRateByDate:pickedDate completion:^(NSArray *heartrates) {
                
                // add both data to plot
                plotController.heartRateDataForPlot = [FitbitHeartRate getDataForPlotFromHeartRateData:heartrates];
                plotController.sleepDataForPlot = [FitbitSleep getDataForPlotFromSleepData:sleepData];
                
                NSLog(@"The size of heart rate data : %lu", (unsigned long)plotController.heartRateDataForPlot.count);
                [self presentViewController:plotController animated:YES completion:^{
                    // to do
                }];
                
            }];
        }];
    } else {
        [self sendAlterMessage:@"Please Sign in"];
    }
}

- (void)getUserProfile {
    if (self.isSignedIn) {
        NSLog(@"My name : %@", self.user.displayName);
    }
}


#pragma mark Accessors



- (void)setIsSignedIn:(BOOL)isSignedIn {
    if (isSignedIn) {
        
        self.user = [FitbitUser userWithAPIFetcher:self.fetcher];
        [self.user updateUserProfile];
        
        self.activity = [FitbitActivity activityWithAPIFetcher:self.fetcher];
        
        self.sleep = [FitbitSleep sleepWithAPIFetcher:self.fetcher];
        
        self.heartRate = [FitbitHeartRate heartRateWithAPIFetcher:self.fetcher];
    }
    _isSignedIn = isSignedIn;
}


#pragma mark System Message Method


- (void)sendAlterMessage:(NSString *)message {
    
    // create alter to notify user
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    // pop from nagivation controller when finished
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Date Processing Methods


// negative num go back
// positive num go forward
- (NSString *)getDateByNumberOfDays:(NSInteger)days {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (days) {
        // days * hours * minutes * seconds
        today = [today dateByAddingTimeInterval:days * 24 * 60 * 60];
    }
    
    return [dateFormatter stringFromDate:today];
}

@end
