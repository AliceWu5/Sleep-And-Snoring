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



+ (FitbitActivity *)activityWithAPIFetcher:(APIFetcher *)fetcher;

- (void)getDistanceByDate:(NSDate *)date completion:(void (^)(NSString *distance))handler;
- (void)updateDistanceByDate:(NSDate *)date completion:(void (^)(NSString *distance))handler ;
- (void)updateRecentActivities;


@end
