//
//  StringConverterTests.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/9/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StringConverter.h"
@interface StringConverterTests : XCTestCase

@end

@implementation StringConverterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testConvertStringWithMillisecondsToTimeInterval {
    NSString *dateString = @"12:22:44:112";
    NSTimeInterval time = [StringConverter convertStringToTimeIntervalFrom:dateString];
    int ti = (int)time;
    int milliseconds = (int)(time * 1000) % 1000;
    int seconds = ti % 60;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600);
    NSString *expectedString = [NSString stringWithFormat:@"%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds];
    XCTAssertEqualObjects(dateString, expectedString, @"The converted string did not match the expected convertion");
}

- (void)testConvertStringWithoutMillisecondsToTimeInterval {
    NSString *dateString = @"12:22:44";
    NSTimeInterval time = [StringConverter convertStringToTimeIntervalFrom:dateString];
    int ti = (int)time;
    int seconds = ti % 60;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600);
    NSString *expectedString = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    XCTAssertEqualObjects(dateString, expectedString, @"The converted string did not match the expected convertion");
}

- (void)testConvertNilStringToTimeInterval {
    NSString *dateString = @"00:00:00:000";
    NSTimeInterval time = [StringConverter convertStringToTimeIntervalFrom:nil];
    int ti = (int)time;
    int milliseconds = (int)(time * 1000) % 1000;
    int seconds = ti % 60;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600);
    NSString *expectedString = [NSString stringWithFormat:@"%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds];
    XCTAssertEqualObjects(dateString, expectedString, @"The converted string did not match the expected convertion");
}

- (void)testConvertNonTimeStringToTimeInterval {
    NSString *dateString = @"unrelated";
    NSTimeInterval time = [StringConverter convertStringToTimeIntervalFrom:dateString];
    XCTAssertEqual(time, 0.0f, @"The converted string did not match the expected convertion");
}

- (void)testConvertNonTimeFormattedStringToTimeInterval {
    NSString *dateString = @"hh:ss:aa";
    NSTimeInterval time = [StringConverter convertStringToTimeIntervalFrom:dateString];
    XCTAssertEqual(time, 0.0f, @"The converted string did not match the expected convertion");
}


- (void)testConvertDateToString {
    NSDate *today = [NSDate date];
    NSString *expectedString = @"2015-09-01";
    NSString *convertedString = [StringConverter convertDateToString:today];
    XCTAssertEqualObjects(convertedString, expectedString, @"The converted string did not match the expected convertion");
}

- (void)testConvertNilDateToString {
    NSDate *today = nil;
    NSString *expectedString = @"2015-09-01";
    NSString *convertedString = [StringConverter convertDateToString:today];
    XCTAssertEqualObjects(convertedString, expectedString, @"The converted string did not match the expected convertion");
}

@end
