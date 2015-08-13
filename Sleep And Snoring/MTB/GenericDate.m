//
//  GenericDate.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/7/14.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "GenericDate.h"

@implementation GenericDate

+(NSString *)getCurrentDate {
    return [GenericDate getStringByDate:[NSDate date]];
}

+(NSString *)getYesterdayDate {
    NSDate *today = [NSDate date];
    NSTimeInterval oneDay = -60 * 60 * 24;
    NSDate *yesterday = [today dateByAddingTimeInterval:oneDay];
    return [GenericDate getStringByDate:yesterday];
}

+ (NSString *)getStringByDate:(NSDate *)day {
    // set format
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:day];
}

@end
