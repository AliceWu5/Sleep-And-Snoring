//
//  FitbitUser.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitUser.h"
#import "FitbitAPI.h"

@interface FitbitUser ()
@property (strong, nonatomic)APIFetcher *fetcher;
@property (nonatomic)BOOL isAvailable;

@end

@implementation FitbitUser

- (BOOL)isAvailable {
    return _isAvailable;
}

+ (FitbitUser *)userWithAPIFetcher:(APIFetcher *)fetcher {
    
    FitbitUser *user = [[FitbitUser alloc] init];
    user.fetcher = fetcher;
    user.isAvailable = false;
    [user updateUserProfile];
    return user;
}

- (void)updateUserProfile {
    
    NSString *path = @"/1/user/-/profile.json";
    
    [self.fetcher sendGetRequestToAPIPath:path onCompletion:^(NSData *data, NSError *error) {
        // user profile in JSON
        NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // Use JSON result to create user
        NSDictionary *userDictionary = [fetchResult objectForKey:kFitbitUserProfileKey];
        if (userDictionary) {
            self.age = [[userDictionary objectForKey:kFitbitUserProfileAgeKey] integerValue];
            self.photo = [userDictionary objectForKey:kFitbitUserProfilePhototKey];
            self.dateOfBirth = [userDictionary objectForKey:kFitbitUserProfileDateOfBirthKey];
            self.displayName = [userDictionary objectForKey:kFitbitUserProfileDisplayNameKey];
            self.fullName = [userDictionary objectForKey:kFitbitUserProfileFullNameKey];
            self.gender = [userDictionary objectForKey:kFitbitUserProfileGenderKey];
            self.height = [userDictionary objectForKey:kFitbitUserProfileHeightKey];
            self.heightUnit = [userDictionary objectForKey:kFitbitUserProfileHeightUnitKey];
            self.encodedId = [userDictionary objectForKey:kFitbitUserProfileEncodedIdKey];
            self.isAvailable = true;
            NSLog(@"Finished fetching user profile.");
        }
    }];
}


- (NSString *)description {
    return [NSString stringWithFormat: @"\nFitbit User : Name = %@ Availability = %d", self.displayName, self.isAvailable];
}


@end
