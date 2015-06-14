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
@property NSMutableDictionary *distances;
@end


@implementation FitbitActivity


+ (FitbitActivity *)activityWithJSON:(NSDictionary *)json {
    FitbitActivity *activity = [[FitbitActivity alloc] init];
    NSArray *distances = json[kFitbitActivitiesDistanceKey];
    
    for (NSDictionary *distance in distances) {
        [activity.distances setObject:distance[kFitbitActivitiesDistanceValueKey]
                               forKey:distance[kFitbitActivitiesDistanceDateTimeKey]];
    }
    
    return activity;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nThe distance : %@", self.distances];
}

#pragma mark accessors

- (NSMutableDictionary *)distances {
    if (!_distances) {
        _distances = [[NSMutableDictionary alloc] init];
    }
    return _distances;
}


@end
