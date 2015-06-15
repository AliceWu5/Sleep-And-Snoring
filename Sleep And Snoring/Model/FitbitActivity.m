//
//  FitbitHeart.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/11.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitActivity.h"
#import "FitbitAPI.h"

@interface FitbitActivity ()
@property (strong, nonatomic)NSMutableDictionary *distances;
@property (strong, nonatomic)APIFetcher *fetcher;
@end


@implementation FitbitActivity

#pragma mark initializor

// initializor
+ (FitbitActivity *)activityWithAPIFetcher:(APIFetcher *)fetcher {
    
    FitbitActivity *activity = [[FitbitActivity alloc] init];
    activity.fetcher = fetcher;
    return activity;
}

#pragma mark get/update activities
- (void)getDistanceByDate:(NSDate *)date completion:(void (^)(NSString *distance))handler {

    NSString *dateKey = [self getStringByDate:date];
    NSString *distance = [self.distances objectForKey:dateKey];
    
    if (!distance) {
        // Distance not exist
        NSLog(@"Distance Not Exist, fetching from API.");
        [self updateDistanceByDate:date completion:handler];
    } else {
        handler(self.distances[dateKey]);
    }
}


// Get the most recent activities
- (void)updateRecentActivities {
    // Get today string format
    NSString *date = [self getStringByDate:[NSDate date]];
    
    // Get activities in a week
    NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/distance/date/%@/7d.json", date];
    
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        NSError *jsonError;
        // user activities in recent week in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Use JSON result to create acivity
        NSArray *distances = fetchResult[kFitbitActivitiesDistanceKey];
        
        for (NSDictionary *distance in distances) {
            [self.distances setObject:distance[kFitbitActivitiesDistanceValueKey]
                                   forKey:distance[kFitbitActivitiesDistanceDateTimeKey]];
        }
    }];
}

// Update activities on date
- (void)updateDistanceByDate:(NSDate *)date completion:(void (^)(NSString *distance))handler {
    NSString *dateKey = [self getStringByDate:date];
    
    // Get activity in a day
    NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/distance/date/%@/1d.json", dateKey];
    
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        NSError *jsonError;
        
        // user activities in a day in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Use JSON result to create acivity
        NSArray *distances = fetchResult[kFitbitActivitiesDistanceKey];
        
        for (NSDictionary *distance in distances) {
            [self.distances setObject:distance[kFitbitActivitiesDistanceValueKey]
                               forKey:distance[kFitbitActivitiesDistanceDateTimeKey]];
        }
        // Set callback method
        handler(self.distances[dateKey]);
    }];
}

// use for heart rate
//- (void)getActivityOnCompletion:(void (^)(NSDictionary *))handler {
//    // Get today string format
//    NSString *date = [self getStringByDate:[NSDate date]];
//    
//    // Get activities in a week
//    NSString *path = [NSString stringWithFormat:@"/1/user/-/activities/distance/date/%@/7d.json", date];
//    NSLog(@"The path : %@", path);
//    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
//        NSError *jsonError;
//        // user heart rate since 7 days ago in JSON
//        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
//        
//        NSLog(@"Activity : %@", fetchResult);
//        // Use JSON result to create acivity
//        FitbitActivity *activity = [FitbitActivity activityWithAPIFetcher:self.fetcher];
//        
//        NSLog(@"%@", activity);
//    }];
//    
//}

#pragma mark string processing
- (NSString *)getStringByDate:(NSDate *)day {
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:day];
}


#pragma mark accessors

- (NSMutableDictionary *)distances {
    if (!_distances) {
        _distances = [[NSMutableDictionary alloc] init];
    }
    return _distances;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nThe distance : %@", self.distances];
}

@end
