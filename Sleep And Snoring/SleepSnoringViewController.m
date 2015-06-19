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
#import "Sleep2DLandscapeView.h"

@interface SleepSnoringViewController ()
@property (strong, nonatomic)IBOutlet UIButton *ButtonForSignIn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic)APIFetcher *fetcher;
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)StartSignIn:(UIButton *)sender {
    OAuth2ViewController *authViewController = [[OAuth2ViewController alloc] init];
    authViewController.delegate = self;

    // manually sign out
    //[authViewController signOut];
    
    [[self navigationController] pushViewController:authViewController animated:YES];
}

- (IBAction)fetchData:(UIButton *)sender {
    NSLog(@"%@", sender.titleLabel.text);
    if ([sender.titleLabel.text isEqualToString:@"User"]) {
        // get user data
        [self getUserProfile];
    }
    if ([sender.titleLabel.text isEqualToString:@"Sleep"]) {
        // get sleep data
        [self getSleepData];
    }
    if ([sender.titleLabel.text isEqualToString:@"Activity"]) {
        // get some activities
        [self getActivity];
    }
    
}

- (IBAction)syncData:(UIButton *)sender {
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
        [self sendAlterMessage:@"Please Sign in."];
    }
}

- (void)addItems:(id)item withMessage:(NSString *)message {
    NSLog(@"The message sent : %@", item);
    if ([item isKindOfClass:[APIFetcher class]]) {
        self.fetcher = item;
        self.isSignedIn = true;
    } else {
        [self sendAlterMessage:message];
    }
}

#pragma mark Fitbit API Methods


- (void)getSleepData {
    
    if (self.isSignedIn) {
        // get today's sleep data
        [self.sleep updateSleepByDate:[NSDate date] completion:^(NSArray *sleepData) {
            NSLog(@"GET SLEEP SUCCESSFULLY.");
            
            SleepScatterPlotController *plotController = [[SleepScatterPlotController alloc] init];
            plotController.dataForPlot = [FitbitSleep getDataForPlotFromSleepData:sleepData];
            //plotController.dataForPlot = sleepData;
            [self presentViewController:plotController animated:YES completion:^{
                // to do
            }];
        }];
        
        
    }
}

- (void)getUserProfile {
    if (self.isSignedIn) {
        NSLog(@"My name : %@", self.user.displayName);
    }
}


- (void)getActivity {
    if (self.isSignedIn) {
        [self.activity getDistanceByDate:[NSDate date] completion:^(NSString *distance) {
            NSLog(@"The distance today : %@", distance);
        }];
    }
}


#pragma mark Accessors

- (BOOL)isSignedIn {
    if (!_isSignedIn) {
        [self sendAlterMessage:@"Please Sign in"];
    }
    return _isSignedIn;
}

- (void)setIsSignedIn:(BOOL)isSignedIn {
    if (isSignedIn) {
        [self sendAlterMessage:@"Sucessful!"];
        self.user = [FitbitUser userWithAPIFetcher:self.fetcher];
        [self.user updateUserProfile];
        
        self.activity = [FitbitActivity activityWithAPIFetcher:self.fetcher];
        
        self.sleep = [FitbitSleep sleepWithAPIFetcher:self.fetcher];
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
