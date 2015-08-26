//
//  FitbitHeartRate.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/5.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitHeartRate.h"
#import "FitbitAPI.h"
#import "StringConverter.h"
#import "CorePlot-CocoaTouch.h"

@interface FitbitHeartRate ()

@property (strong, nonatomic)APIFetcher *fetcher;

// constain the main data of heart
@property (strong, nonatomic) NSMutableDictionary *heartRateData;

@end
@implementation FitbitHeartRate

#pragma mark initializor

// initializor
+(FitbitHeartRate *)heartRateWithAPIFetcher:(APIFetcher *)fetcher {
    FitbitHeartRate *heartRate = [[FitbitHeartRate alloc] init];
    heartRate.fetcher = fetcher;
    return heartRate;
}

- (void)updateHeartRateByDate:(NSDate *)date completion:(void (^)(NSArray *heartrates, BOOL hasError))handler {
    NSString *dateKey = [StringConverter convertDateToString:date];
    
    // Get heart rate in a day
    NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/heart/date/%@/1d/1sec.json", dateKey];
    NSLog(@"%@", path);
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        
        if (!error) {
            // user heart rate in a day in JSON
            NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:[error userInfo][@"data"] options:kNilOptions error:nil]);
            
            // Use JSON result to create heart rate
            NSDictionary *heartrate = fetchResult[kFitbitHeartRateIntradayKey];
            NSArray *dataset = heartrate[kFitbitHeartRateIntradayDatasetKey];
            handler(dataset, NO);
            
            // Store data
            [self.heartRateData setObject:dataset forKey:dateKey];
        } else {
            // do something
            NSLog(@"Errors occur when fetching heart rate data.");
            handler(nil, YES);
        }

    }];
}

#pragma mark prepare for plot


+(NSArray *)getDataForPlotFromHeartRateData:(NSArray *)heartRateData {
    NSMutableArray *dataForPlot = [[NSMutableArray alloc] init];
    
    for (NSDictionary *heartRate in heartRateData) {
        
        // for each section in the heart rate data
        
            NSString *timeString = heartRate[kFitbitHeartRateIntradayDatasetTimeKey];
            NSTimeInterval xVal = [StringConverter convertStringToTimeIntervalFrom:timeString];
            int yVal = ((NSString *)heartRate[kFitbitHeartRateIntradayDatasetValueKey]).intValue;
            
            [dataForPlot addObject:@{
                                     @(CPTScatterPlotFieldX): @(xVal),
                                     @(CPTScatterPlotFieldY): @(yVal)
                                     }
             ];
        
    }
    return  dataForPlot;
}


#pragma mark accessors


- (NSString *)description {
    return [NSString stringWithFormat:@"\nThe heartRate : unknown"];
}
@end
