//
//  ViewController.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/13.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "SleepSnoringViewController.h"
#import "LinePlotController.h"
#import "SVProgressHUD.h"
#import "APIFetcher.h"
#import "FitbitSleep.h"
#import "FitbitHeartRate.h"
#import "FitbitUser.h"
#import "Sleep2DLandscapeView.h"
#import "AudioModel.h"
#import "StringConverter.h"
#import "SSKeychain.h"

// keys for SSKeychain
static NSString *const kSleepAndSnoringService          = @"Sleep And Snoring";
static NSString *const kSleepAndSnoringAccessAccount    = @"com.sleepandsnoring.accesstoken";
static NSString *const kSleepAndSnoringRefreshAccount   = @"com.sleepandsnoring.refreshtoken";

@interface SleepSnoringViewController ()

@property (strong, nonatomic) IBOutlet UILabel *loginStatus;
@property (strong, nonatomic) IBOutlet UISwitch *sleepSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *heartRateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *audioSwitch;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic)APIFetcher *fetcher;
@property (strong, nonatomic)OAuth2Authentication *auth;
@property (strong, nonatomic)FitbitHeartRate *heartRate;
@property (strong, nonatomic)FitbitSleep *sleep;


@property (nonatomic)BOOL isSignedIn;
@property (assign)BOOL isLoading;
@end

@implementation SleepSnoringViewController

-(void)viewDidAppear:(BOOL)animated
{
    [self updateLoginStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set indicator
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.indicator.hidesWhenStopped = YES;
    // Do any additional setup after loading the view, typically from a nib.
    
    // init UI
    [self initNavigationBarItems];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    // init oauth
    self.auth = [OAuth2Authentication fitbitAuth];
    self.auth.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBarItems {
    self.navigationItem.title = @"Fitbit Data";
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
        
        APIFetcher *fetcher = [APIFetcher fetcherWithOAuth2:self.auth accessToken:accessToken refreshToken:refreshToken];
        self.fetcher = fetcher;
        
    } else {
        NSLog(@"Need to log in.");
        self.isSignedIn = NO;
    }
    [self updateUserInfo];

}

// update login status
-(void)updateUserInfo {
    if (self.isSignedIn) {
        FitbitUser *user = [FitbitUser userWithAPIFetcher:self.fetcher];
        [user updateUserProfileOnCompletion:^(BOOL isFinished) {
            if (isFinished) {
                self.loginStatus.text = [NSString stringWithFormat:@"Signed in as user %@", user.fullName];
            }
        }];
        
    } else {
        self.loginStatus.text = @"Not signed in";
    }
}

#pragma mark Press button methods

- (IBAction)startSignIn:(UIButton *)sender {
    [self.auth openAuthorizationPage];
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
    [self updateUserInfo];
}

- (IBAction)plotSelectedData:(UIButton *)sender {

    BOOL hrSwitch = self.heartRateSwitch.on;
    BOOL sleepSwitch = self.sleepSwitch.on;
    BOOL audioSwitch = self.audioSwitch.on;
    
    if (self.isSignedIn) {
        
        self.isLoading = YES;
        // init plot view
        LinePlotController *plot = [[LinePlotController alloc] init];
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
        [self startLoading];
        
        if (audioSwitch && !sleepSwitch && !hrSwitch) {
            plot.audioDataForPlot = [self getAudioData];
            [self dismissSVProgressHUD];
            [self presentViewController:plot animated:YES completion:^{
                // to do
            }];
        }
        
    } else if (audioSwitch && !sleepSwitch && !hrSwitch) {
        LinePlotController *plot = [[LinePlotController alloc] init];
        plot.audioDataForPlot = [self getAudioData];
        [self dismissSVProgressHUD];
        [self presentViewController:plot animated:YES completion:^{
            // to do
        }];
    } else {
        [self sendAlterMessage:@"Please Sign in"];
    }
}

- (void)syncData:(UIButton *)sender {
    NSLog(@"Synchronize data from Fitbit.");
    if (self.isSignedIn) {
        [self.indicator startAnimating];
        
        //[self.user updateUserProfile];
        //[self.activity updateRecentActivities];
        [self.sleep updateSleepByDate:[NSDate date] completion:^(NSArray *sleepData, BOOL hasError) {
            [self.indicator stopAnimating];
            NSLog(@"should stop animating");
        }];
    } else {
        // to do
        [self sendAlterMessage:@"Please Sign in"];
    }
}

-(void)getAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken {
    self.fetcher = [APIFetcher fetcherWithOAuth2:self.auth accessToken:accessToken refreshToken:refreshToken];
    self.isSignedIn = YES;
    //clear keychains first
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    [SSKeychain deletePasswordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];

    // set the keychain when fetch is created
    BOOL accessTokenIsSet = [SSKeychain setPassword:self.fetcher.accessToken forService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    BOOL refreshTokenIsSet = [SSKeychain setPassword:self.fetcher.refreshToken forService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];

    NSLog(@"Access Token Set : %i Refresh Token Set : %i",accessTokenIsSet ,refreshTokenIsSet);

    // send alter message only when user have log in action
    [self sendAlterMessage:@"Sucessful!"];
    [self updateUserInfo];

}

#pragma mark Fitbit API Methods

- (void)getSleepDataOnCompletion:(void (^)(NSArray *sleepData))handler {
    
    if (self.isSignedIn) {
        // get selected date sleep data
        NSDate *pickedDate = self.datePicker.date;
        [self.sleep getSleepByDate:pickedDate completion:^(NSArray *sleepData, BOOL hasError) {
            if (hasError) {
                [self sendAlterMessage:@"Please sign in"];
            } else {
                handler([FitbitSleep getDataForPlotFromSleepData:sleepData]);
            }
        }];
    } else {
        handler(nil);
    }
}

-(void)getHeartRateDataOnCompletion:(void (^)(NSArray *heartRateData))handler {
    if (self.isSignedIn) {
        // get selected date sleep data
        NSDate *pickedDate = self.datePicker.date;
        [self.heartRate updateHeartRateByDate:pickedDate completion:^(NSArray *heartrates, BOOL hasError) {
            if (hasError) {
                [self sendAlterMessage:@"Please sign in"];
            } else {
                handler([FitbitHeartRate getDataForPlotFromHeartRateData:heartrates]);
            }
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

#pragma mark Accessors


-(FitbitSleep *)sleep {
    NSLog(@"The f: %@ s: %@",_fetcher,_sleep);
    if (_fetcher && !_sleep) {
        NSLog(@"Create fitbit sleep.");
        _sleep = [FitbitSleep sleepWithAPIFetcher:self.fetcher];
    }
    return _sleep;
}

-(FitbitHeartRate *)heartRate {
    if (_fetcher && !_heartRate) {
        _heartRate = [FitbitHeartRate heartRateWithAPIFetcher:self.fetcher];
    }
    return _heartRate;
}

//#pragma mark SystemMessageMethod


-(void)sendAlterMessage:(NSString *)message {
    
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

#pragma mark Loading indicator methods
    
-(void)stopLoading {
    [SVProgressHUD dismiss];
    self.isLoading = NO;
}

-(void)startLoading {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoading)
                                                 name:SVProgressHUDDidReceiveTouchEventNotification
                                               object:nil];
}

-(void)dismissSVProgressHUD {
    [SVProgressHUD dismiss];
}


@end
