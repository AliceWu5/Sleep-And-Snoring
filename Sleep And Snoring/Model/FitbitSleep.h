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

- (NSArray *)getSleepTimeline;
- (void)updateRecentSleep;
- (void)updateSleepByDate:(NSDate *)date completion:(void (^)(NSDictionary *sleepData))handler;
- (void)getSleepByDate:(NSDate *)date completion:(void (^)(NSDictionary *sleepData))handler;
- (void)getSleepTimelineByDate:(NSDate *)date completion:(void (^)(NSArray *minuteData))handler;
- (void)getSummaryByDate:(NSDate *)date completion:(void (^)(NSDictionary *))handler;

@end
