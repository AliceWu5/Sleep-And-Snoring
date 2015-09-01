//
//  StringConverter.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/16.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "StringConverter.h"

@implementation StringConverter


+ (NSTimeInterval)convertStringToTimeIntervalFrom:(NSString *)timeString {
    
    // time in hh:mm:ss format
    NSArray *time = [timeString componentsSeparatedByString:@":"];
    if ([time count] != 3 && [time count] != 4) return 0.0f;
    
    NSString *hour = time[0];
    NSString *minute = time[1];
    NSString *second = time[2];
    if ([time count] == 4) {
        NSString *millisecond = time[3];
        return hour.integerValue * 60 * 60 + minute.integerValue * 60 + second.integerValue + millisecond.intValue * 0.001;
    }
    return hour.integerValue * 60 * 60 + minute.integerValue * 60 + second.integerValue;
}

+ (NSString *)convertDateToString:(NSDate *)day {
    NSDate *date = day;
    if (!day) {
        date = [NSDate date];
    }
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

@end
