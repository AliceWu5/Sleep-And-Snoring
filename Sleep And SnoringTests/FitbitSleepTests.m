//
//  FitbitSleepTests.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/9/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FitbitSleep.h"
#import "SSKeychain.h"
#import "Constants.h"
@interface FitbitSleepTests : XCTestCase
@property (nonatomic)FitbitSleep *sleep;
@end

@implementation FitbitSleepTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *accessToken = [SSKeychain passwordForService:kSleepAndSnoringService account:kSleepAndSnoringAccessAccount];
    NSString *refreshToken = [SSKeychain passwordForService:kSleepAndSnoringService account:kSleepAndSnoringRefreshAccount];
    
    APIFetcher *fetcher = [APIFetcher fetcherWithOAuth2:[OAuth2Authentication fitbitAuth] accessToken:accessToken refreshToken:refreshToken];
    self.sleep = [FitbitSleep sleepWithAPIFetcher:fetcher];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
