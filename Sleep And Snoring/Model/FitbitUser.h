//
//  FitbitUser.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetcher.h"
@interface FitbitUser : NSObject
@property (nonatomic) NSUInteger age;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *dateOfBirth;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *height;
@property (strong, nonatomic) NSString *heightUnit;
@property (strong, nonatomic) NSString *encodedId;

+ (FitbitUser *)userWithAPIFetcher:(APIFetcher *)fetcher;
- (void)updateUserProfile;
- (BOOL)isAvailable;
@end
