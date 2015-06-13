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
@property (strong, nonatomic) NSArray *sleepData;
// summary of sleep in this day
@property (strong, nonatomic) NSDictionary *summary;


@end


@implementation FitbitSleep


// Designated initializor
+ (FitbitSleep *)sleepWithJSON:(NSDictionary *)json {
    FitbitSleep *fitbitSleep = [[FitbitSleep alloc] init];
    fitbitSleep.sleepData = [json objectForKey:kFitbitSleepDataKey];
    fitbitSleep.summary = [json objectForKey:kFitbitSleepSummaryKey];
    NSLog(@"The type of sleep : %@",[json class]);
    NSLog(@"The type of sleep data: %@",[fitbitSleep.sleepData class]);
    NSLog(@"The type of sleep summary: %@",[fitbitSleep.summary class]);
    return fitbitSleep;
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

// Make it nil if empty array
- (void)setSleepData:(NSArray *)sleepData {
    
    if ([sleepData count] == 0) {
        _sleepData = nil;
    } else {
        _sleepData = sleepData;
    }
}



@end
