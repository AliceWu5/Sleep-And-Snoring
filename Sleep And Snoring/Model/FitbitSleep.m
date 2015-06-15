//
//  FitbitSleep.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitSleep.h"
#import "FitbitAPI.h"

@interface FitbitSleep ()

// constain the main data of sleep in a day
@property (strong, nonatomic) NSMutableDictionary *sleepData;
// summary of sleep in this day
@property (strong, nonatomic) NSMutableDictionary *summarys;

@property (strong, nonatomic) APIFetcher *fetcher;
@end


@implementation FitbitSleep

#pragma mark initializor

// Designated initializor
+ (FitbitSleep *)sleepWithAPIFetcher:(APIFetcher *)fetcher {
    FitbitSleep *fitbitSleep = [[FitbitSleep alloc] init];
    fitbitSleep.fetcher = fetcher;
//    fitbitSleep.sleepData = [json objectForKey:kFitbitSleepDataKey];
//    fitbitSleep.summary = [json objectForKey:kFitbitSleepSummaryKey];
//    NSLog(@"The type of sleep : %@",[json class]);
//    NSLog(@"The type of sleep data: %@",[fitbitSleep.sleepData class]);
//    NSLog(@"The type of sleep summary: %@",[fitbitSleep.summary class]);
    return fitbitSleep;
}

#pragma mark update/get methods

- (void)updateRecentSleep {
    NSDate *today = [NSDate date];
    NSString *dateString = [self getStringByDate:today];

    NSString *path = [NSString stringWithFormat:@"/1/user/-/sleep/date/%@.json", dateString];
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        
        // sleep data in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *sleeps = fetchResult[kFitbitSleepDataKey];
        NSDictionary *summary = fetchResult[kFitbitSleepSummaryKey];
        
        if ([sleeps count] == 0) {
            NSLog(@"%@'s sleep is empty.", dateString);
        } else {
            NSLog(@"The sleep result : %@", sleeps[0]);
        }
        
        // Store data
        [self.summarys setObject:summary forKey:dateString];
        [self.sleepData setObject:sleeps forKey:dateString];
        
        
    }];
}

- (void)updateSleepByDate:(NSDate *)date completion:(void (^)(NSDictionary *sleepData))handler {
    
}
- (void)getSleepByDate:(NSDate *)date completion:(void (^)(NSDictionary *sleepData))handler {
    
}



- (NSArray *)getSleepTimeline {
    
    NSMutableArray *timeline = [[NSMutableArray alloc] init];
    
    // all the sleeps in a day
    for (NSDictionary *sleep in self.sleepData ) {

        // get the first minutes data for each sleep
        for (NSDictionary *minute in [sleep objectForKey:kFitbitSleepDataMinuteDataKey]) {
            
            NSString *date = [minute objectForKey:kFitbitSleepDataMinuteDataDateTimeKey];
            NSNumber *value = [minute objectForKey:kFitbitSleepDataMinuteDataValueKey];
            NSLog(@"The first date time : %@", date);
            NSLog(@"The first value : %@", value);
            break;
        }
    }
    
    return timeline;
}


#pragma mark string processing

- (NSString *)getStringByDate:(NSDate *)day {
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:day];
}

#pragma mark accessors
// Make it nil if empty array
- (void)setSleepData:(NSMutableDictionary *)sleepData {
    
    if ([sleepData count] == 0) {
        _sleepData = nil;
    } else {
        _sleepData = sleepData;
    }
}


@end
