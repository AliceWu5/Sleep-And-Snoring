//
//  FitbitHeart.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/11.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitActivity.h"


@interface FitbitActivity ()
@property NSString *distances;
@end


@implementation FitbitActivity

+ (FitbitActivity *)activityWithJSON:(NSDictionary *)json {
    FitbitActivity *activity = [[FitbitActivity alloc] init];
    NSDictionary *summary = json[@"summary"];
    NSArray *distances = summary[@"distances"];
    NSLog(@"The distances total : %@", distances[0]);
    
    if ([distances[0][@"activity"] isEqualToString:@"total"]) {
        // the unit needs to be determined
        activity.distances = [NSString stringWithFormat:@"%@ unit", distances[0][@"distance"]];
    } else {
        activity.distances = @"0 unit";
    }
    
    NSLog(@"The distance : %@", activity.distances);
    
    return activity;
}

@end
