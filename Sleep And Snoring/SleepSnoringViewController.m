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
#import "SVProgressHUD.h"
#import "APIFetcher.h"
#import "FitbitSleep.h"
#import "FitbitUser.h"
#import "FitbitActivity.h"
#import "FitbitHeartRate.h"
#import "Sleep2DLandscapeView.h"
#import "GenericDate.h"
#import "AudioModel.h"
#import "StringConverter.h"
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


@property (nonatomic)BOOL isSignedIn;
@property (assign)BOOL isLoading;
@end

@implementation SleepSnoringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set indicator
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.indicator.hidesWhenStopped = YES;
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initNavigationBarItems];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self updateLoginStatus];
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

- (void)updateLoginStatus {
    
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

#pragma mark Press button methods

- (IBAction)startSignIn:(UIButton *)sender {
    
    // init view for login
    OAuth2ViewController *authViewController = [[OAuth2ViewController alloc] init];
    authViewController.delegate = self;
    
    // push view for login
    [[self navigationController] pushViewController:authViewController animated:YES];
}

- (IBAction)startSignOut:(UIButton *)sender {
    // user sign out
    [self sendAlterMessage:@"You have signed out"];
    
    // delete keychains
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
    
    // clear fetcher
    self.fetcher = nil;
    self.isSignedIn = NO;
}

- (IBAction)startTest:(UIButton *)sender {
    [self sendCustomAlterView];
}

- (IBAction)plotSelectedData:(UIButton *)sender {

    if (self.isSignedIn) {
        BOOL hrSwitch = self.heartRateSwitch.on;
        BOOL sleepSwitch = self.sleepSwitch.on;
        BOOL audioSwitch = self.audioSwitch.on;
        
        self.isLoading = YES;
        // init plot view
        SleepScatterPlotController *plot = [[SleepScatterPlotController alloc] init];
        if (hrSwitch && sleepSwitch && audioSwitch) {
            [self getSleepDataOnCompletion:^(NSArray *sleepData) {
                [self getHeartRateDataOnCompletion:^(NSArray *heartRateData) {
                    plot.sleepDataForPlot = sleepData;
                    plot.heartRateDataForPlot = heartRateData;
                    plot.audioDataForPlot = [self getAudioData];
                    if (self.isLoading) {
                        [self dismissSVProgressHUD];
                        [self presentViewController:plot animated:YES completion:^{
                        // to do
                        }];
                    }
                }];
            }];
        } else if (hrSwitch && sleepSwitch) {
            [self getSleepDataOnCompletion:^(NSArray *sleepData) {
                [self getHeartRateDataOnCompletion:^(NSArray *heartRateData) {
                    plot.sleepDataForPlot = sleepData;
                    plot.heartRateDataForPlot = heartRateData;
                    if (self.isLoading) {
                        [self dismissSVProgressHUD];
                        [self presentViewController:plot animated:YES completion:^{
                            // to do
                        }];
                    }
                }];
            }];
        } else if (hrSwitch && audioSwitch) {
            [self getHeartRateDataOnCompletion:^(NSArray *heartRateData) {
                plot.heartRateDataForPlot = heartRateData;
                plot.audioDataForPlot = [self getAudioData];
                if (self.isLoading) {
                    [self dismissSVProgressHUD];
                    [self presentViewController:plot animated:YES completion:^{
                        // to do
                    }];
                }
            }];
        } else if (sleepSwitch && audioSwitch) {
            [self getSleepDataOnCompletion:^(NSArray *sleepData) {
                plot.sleepDataForPlot = sleepData;
                plot.audioDataForPlot = [self getAudioData];
                if (self.isLoading) {
                    [self dismissSVProgressHUD];
                    [self presentViewController:plot animated:YES completion:^{
                        // to do
                    }];
                }
            }];
        } else if (hrSwitch) {
            [self getHeartRateDataOnCompletion:^(NSArray *heartRateData) {
                plot.heartRateDataForPlot = heartRateData;
                plot.audioDataForPlot = [self getAudioData];
                if (self.isLoading) {
                    [self dismissSVProgressHUD];
                    [self presentViewController:plot animated:YES completion:^{
                        // to do
                    }];
                }
            }];
        } else if (sleepSwitch) {
            [self getSleepDataOnCompletion:^(NSArray *sleepData) {
                plot.sleepDataForPlot = sleepData;
                plot.audioDataForPlot = [self getAudioData];
                if (self.isLoading) {
                    [self dismissSVProgressHUD];
                    [self presentViewController:plot animated:YES completion:^{
                        // to do
                    }];
                }
            }];
        }
        [self sendCustomAlterView];
        
        if (audioSwitch && !sleepSwitch && !hrSwitch) {
            plot.audioDataForPlot = [self getAudioData];
            [self dismissSVProgressHUD];
            [self presentViewController:plot animated:YES completion:^{
                // to do
            }];
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

    if ([item isKindOfClass:[APIFetcher class]]) {
        
        APIFetcher *fetcher = (APIFetcher *)item;
        
        // clear keychains first
        [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
        [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
        
        // set the keychain when fetch is created
        BOOL accessTokenIsSet = [SSKeychain setPassword:fetcher.accessToken forService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
        BOOL refreshTokenIsSet = [SSKeychain setPassword:fetcher.refreshToken forService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
        
        NSLog(@"Access Token Set : %i Refresh Token Set : %i",accessTokenIsSet ,refreshTokenIsSet);

        self.fetcher = item;
        self.isSignedIn = true;
        
        // send alter message only when user have log in action
        [self sendAlterMessage:@"Sucessful!"];

    } else {
        [self sendAlterMessage:message];
    }
}

#pragma mark Fitbit API Methods


- (void)getSleepDataOnCompletion:(void (^)(NSArray *sleepData))handler {
    
    if (self.isSignedIn) {
        // get selected date sleep data
        NSDate *pickedDate = self.datePicker.date;
        [self.sleep getSleepByDate:pickedDate completion:^(NSArray *sleepData) {
            handler([FitbitSleep getDataForPlotFromSleepData:sleepData]);
        }];
    } else {
        handler(nil);
    }
}

-(void)getHeartRateDataOnCompletion:(void (^)(NSArray *heartRateData))handler {
    if (self.isSignedIn) {
        // get selected date sleep data
        NSDate *pickedDate = self.datePicker.date;
        [self.heartRate updateHeartRateByDate:pickedDate completion:^(NSArray *heartrates) {
            handler([FitbitHeartRate getDataForPlotFromHeartRateData:heartrates]);
        }];
    } else {
        handler(nil);
    }
}

// get local audio level file
-(NSArray *)getAudioData {
    AudioModel *model = [AudioModel shareInstance];
    return [AudioModel getDataForPlotFromAudioData:[model getAudioByDate:self.datePicker.date]];
}

- (void)getUserProfile {
    if (self.isSignedIn) {
        NSLog(@"My name : %@", self.user.displayName);
    }
}


#pragma mark Accessors


- (void)setIsSignedIn:(BOOL)isSignedIn {
    if (isSignedIn) {
        
    }
    _isSignedIn = isSignedIn;
}


-(FitbitUser *)user {
    if (_fetcher && !_user) {
        _user = [FitbitUser userWithAPIFetcher:self.fetcher];
    }
    return _user;
}


-(FitbitSleep *)sleep {
    NSLog(@"The f: %@ s: %@",_fetcher,_sleep);
    if (_fetcher && !_sleep) {
        NSLog(@"Create fitbit sleep.");
        _sleep = [FitbitSleep sleepWithAPIFetcher:self.fetcher];
    }
    return _sleep;
}


-(FitbitActivity *)activity {
    if (_fetcher && !_activity) {
        _activity = [FitbitActivity activityWithAPIFetcher:self.fetcher];
    }
    return _activity;
}


-(FitbitHeartRate *)heartRate {
    if (_fetcher && !_heartRate) {
        _heartRate = [FitbitHeartRate heartRateWithAPIFetcher:self.fetcher];
    }
    return _heartRate;
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

-(void)sendCustomAlterView {

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoadingData)
                                                 name:SVProgressHUDDidReceiveTouchEventNotification
                                               object:nil];
}

-(void)stopLoadingData {
    [SVProgressHUD dismiss];
    self.isLoading = NO;
}
-(void)dismissSVProgressHUD {
    [SVProgressHUD dismiss];
}


@end
