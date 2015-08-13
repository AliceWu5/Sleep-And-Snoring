//
//  FitbitHeartRate.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/5.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitHeartRate.h"
@interface FitbitHeartRate ()
@property (strong, nonatomic)APIFetcher *fetcher;

@end
@implementation FitbitHeartRate

#pragma mark initializor

// initializor
+(FitbitHeartRate *)heartRateWithAPIFetcher:(APIFetcher *)fetcher {
    FitbitHeartRate *heartRate = [[FitbitHeartRate alloc] init];
    heartRate.fetcher = fetcher;
    return heartRate;
}

-(void)updateHeartRateByDate:(NSDate *)date completion:(void (^)(NSString *))handler {
    NSString *dateKey = [self getStringByDate:date];
    
    // Get activity in a day
    NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/heart/date/%@/1d/1sec.json", dateKey];
    NSLog(@"%@", path);
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        NSError *jsonError;
        
        // user activities in a day in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        NSLog(@"The heartrate : %@", fetchResult);
        NSLog(@"%@", jsonError);
        // Use JSON result to create heart rate
        //NSArray *distances = fetchResult[kFitbitActivitiesDistanceKey];
        
//        for (NSDictionary *distance in distances) {
//            [self.distances setObject:distance[kFitbitActivitiesDistanceValueKey]
//                               forKey:distance[kFitbitActivitiesDistanceDateTimeKey]];
//        }
        // Set callback method
        //handler(self.distances[dateKey]);
    }];
}


#pragma mark string processing
- (NSString *)getStringByDate:(NSDate *)day {
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:day];
}


#pragma mark accessors

//- (NSMutableDictionary *)distances {
//    if (!_distances) {
//        _distances = [[NSMutableDictionary alloc] init];
//    }
//    return _distances;
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nThe heartRate : unknown"];
}
@end
