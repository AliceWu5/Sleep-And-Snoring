//
//  FitbitSleep.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetcher.h"
@interface FitbitSleep : NSObject



+ (FitbitSleep *)sleepWithAPIFetcher:(APIFetcher *)fetcher;

// process raw sleep data
+ (NSArray *)getDataForPlotFromSleepData:(NSArray *)sleepData;

//- (NSArray *)getSleepTimeline;
- (void)updateRecentSleep;
- (void)updateSleepByDate:(NSDate *)date completion:(void (^)(NSArray *sleepData))handler;
- (void)getSleepByDate:(NSDate *)date completion:(void (^)(NSArray *sleepData))handler;
//- (void)getSleepTimelineByDate:(NSDate *)date completion:(void (^)(NSArray *minuteData))handler;
//- (void)getSummaryByDate:(NSDate *)date completion:(void (^)(NSDictionary *))handler;

@end
