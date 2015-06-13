//
//  FitbitSleep.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FitbitSleep : NSObject

+ (FitbitSleep *)sleepWithJSON:(NSDictionary *)json;

- (NSArray *)getSleepTimeline;
@end
