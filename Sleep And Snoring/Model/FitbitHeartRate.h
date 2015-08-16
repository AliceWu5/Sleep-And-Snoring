//
//  FitbitHeartRate.h
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/5.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetcher.h"
@interface FitbitHeartRate : NSObject

+ (FitbitHeartRate *)heartRateWithAPIFetcher:(APIFetcher *)fetcher;

+(NSArray *)getDataForPlotFromHeartRateData:(NSArray *)heartRateData;

//- (void)getHeartRateByDate:(NSDate *)date completion:(void (^)(NSString *distance))handler;
- (void)updateHeartRateByDate:(NSDate *)date completion:(void (^)(NSArray *heartrates))handler ;
//- (void)updateRecentHeartRate;


@end
