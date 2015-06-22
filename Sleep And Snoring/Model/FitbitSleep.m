//
//  FitbitSleep.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitSleep.h"
#import "FitbitAPI.h"

static NSTimeInterval const oneMinute = 60;

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
    return fitbitSleep;
}

#pragma mark update/get methods

- (void)updateRecentSleep {
    NSDate *today = [NSDate date];
    [self updateSleepByDate:today completion:^(NSArray *sleepData) {
        NSLog(@"Get today's sleep data.");
    }];
}

- (void)updateSleepByDate:(NSDate *)date completion:(void (^)(NSArray *))handler {
    //NSDate *yesterday = [date dateByAddingTimeInterval:- 24 * 60 * 60];
    NSString *dateKey = [self getStringByDate:date];
    
    NSString *path = [NSString stringWithFormat:@"/1/user/-/sleep/date/%@.json", dateKey];
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        NSLog(@"%@", path);
        // sleep data in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *sleeps = fetchResult[kFitbitSleepDataKey];
        NSDictionary *summary = fetchResult[kFitbitSleepSummaryKey];

        if ([sleeps count] == 0) {
            NSLog(@"%@'s sleep is empty.", dateKey);
            NSLog(@"%@", sleeps);
        }
        
        // Store data
        [self.summarys setObject:summary forKey:dateKey];
        [self.sleepData setObject:sleeps forKey:dateKey];
        
        handler(sleeps);
    }];
}

- (void)getSleepByDate:(NSDate *)date completion:(void (^)(NSArray *))handler {
    
    NSString *dateKey = [self getStringByDate:date];
    NSArray *sleepDataByDate = [self.sleepData objectForKey:dateKey];
    if (!sleepDataByDate) {
        [self updateSleepByDate:date completion:^(NSArray *sleepData) {
            handler(sleepData);
        }];
    } else {
        handler(sleepDataByDate);
    }

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

#pragma mark prepare for plot
+(NSArray *)getDataForPlotFromSleepData:(NSArray *)sleepData {

    NSMutableArray *dataForPlot = [[NSMutableArray alloc] init];

    for (NSDictionary *sleep in sleepData) {
        // for each sleep at the date
        NSArray *minuteData = [sleep objectForKey:kFitbitSleepDataMinuteDataKey];
        // for each minute in the minutedata
        for (NSDictionary* minute in minuteData) {
            
            NSString *timeString = [minute[kFitbitSleepDataMinuteDataDateTimeKey] substringToIndex:5];
            NSTimeInterval xVal = [FitbitSleep convertStringToTimeIntervalFrom:timeString];
            NSNumber *yVal = minute[kFitbitSleepDataMinuteDataValueKey];

            [dataForPlot addObject:@{
                                     @"x": @(xVal),
                                     @"y": yVal
                                     }
             ];

            break;
        }
    }
    
    return  dataForPlot;
}

+ (NSTimeInterval)convertStringToTimeIntervalFrom:(NSString *)timeString {

    // time in hh:ss format
    NSArray *time = [timeString componentsSeparatedByString:@":"];
    NSString *hour = time[0];
    NSString *second = time[1];
    
    return hour.integerValue * 60 + second.integerValue;
}


#pragma mark string processing

- (NSString *)getStringByDate:(NSDate *)day {
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:day];
}

#pragma mark accessors

-(NSMutableDictionary *)sleepData {
    if (!_sleepData) {
        _sleepData = [[NSMutableDictionary alloc] init];
    }
    return _sleepData;
}

@end
