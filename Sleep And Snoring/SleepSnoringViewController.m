//
//  ViewController.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/13.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "SleepSnoringViewController.h"
#import "OAuth2ViewController.h"
#import "APIFetcher.h"
#import "FitbitSleep.h"
#import "FitbitUser.h"
#import "FitbitActivity.h"
#import "Sleep2DLandscapeView.h"
@interface SleepSnoringViewController ()
@property (strong, nonatomic) IBOutlet UIButton *ButtonForSignIn;
@property (strong, nonatomic) APIFetcher *fetcher;
@property BOOL isSignedIn;
@end

@implementation SleepSnoringViewController
@synthesize isSignedIn = _isSignedIn;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [authViewController signOut];
    
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
        NSString *date = [self getDateByNumberOfDays:0];
        NSLog(@"The date is : %@", date);
        NSString *path = [NSString stringWithFormat:@"/1/user/-/sleep/date/%@.json", date];
        
        [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
            // Sleep data in JSON
            NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            // Use JSON result to create sleep model
            FitbitSleep *sleep = [FitbitSleep sleepWithJSON:fetchResult];
            [sleep getSleepTimeline];
            
        }];
    }
    
    //    Sleep2DLandscapeView *sleepView = [[Sleep2DLandscapeView alloc] initWithFrame:self.view.frame];
    //    [self.view addSubview:sleepView];
}

- (void)getUserProfile {
    if (self.isSignedIn) {
        NSString *path = @"/1/user/-/profile.json";
        
        [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
            // user profile in JSON
            NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            // Use JSON result to create user
            FitbitUser *user = [FitbitUser userWithJSON:fetchResult];
            
        }];
        
    }
}


- (void)getActivity {
    if (self.isSignedIn) {
        NSString *date = [self getDateByNumberOfDays:0];
        NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/date/%@.json", date];
        NSLog(@"The path : %@", path);
        [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
            NSError *jsonError;
            // user heart rate since 7 days ago in JSON
            NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            
            NSLog(@"Activity : %@", fetchResult);
            // Use JSON result to create acivity
            FitbitActivity *activity = [FitbitActivity activityWithJSON:fetchResult];
            
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


- (NSString *)getDateByNumberOfDays:(NSInteger)days {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (days) {
        // days * hours * minutes * seconds
        today = [today dateByAddingTimeInterval:-days * 24 * 60 * 60];
    }
    
    return [dateFormatter stringFromDate:today];
}

@end
