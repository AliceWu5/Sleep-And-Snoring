//
//  StringConverter.h
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/16.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringConverter : NSObject

+ (NSTimeInterval)convertStringToTimeIntervalFrom:(NSString *)timeString;

+ (NSString *)convertDateToString:(NSDate *)day;

@end
