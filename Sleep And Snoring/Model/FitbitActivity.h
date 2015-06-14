//
//  FitbitHeart.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/11.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetcher.h"
@interface FitbitActivity : NSObject


+ (FitbitActivity *)activityWithJSON:(NSDictionary *)json;

+ (FitbitActivity *)activityWithAPIFetcher:(APIFetcher *)fetcher;

- (void)getDistanceByDate:(NSDate *)date completion:(void (^)(NSDictionary *))handler ;;
- (void)updateRecentActivities;
- (void)updateActivitiesWithDate:(NSDate *)date completion:(void (^)(NSDictionary *))handler ;


@end
