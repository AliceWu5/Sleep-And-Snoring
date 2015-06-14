//
//  FitbitUser.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/4.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "FitbitUser.h"
#import "FitbitAPI.h"
@implementation FitbitUser

+ (FitbitUser *)userWithJSON:(NSDictionary *)json {
    
    FitbitUser *user = [[FitbitUser alloc] init];
    NSDictionary *userDictionary = [json objectForKey:kFitbitUserProfileKey];
    if (userDictionary) {
        user.age = [[userDictionary objectForKey:kFitbitUserProfileAgeKey] integerValue];
        user.photo = [userDictionary objectForKey:kFitbitUserProfilePhototKey];
        user.dateOfBirth = [userDictionary objectForKey:kFitbitUserProfileDateOfBirthKey];
        user.displayName = [userDictionary objectForKey:kFitbitUserProfileDisplayNameKey];
        user.fullName = [userDictionary objectForKey:kFitbitUserProfileFullNameKey];
        user.gender = [userDictionary objectForKey:kFitbitUserProfileGenderKey];
        user.height = [userDictionary objectForKey:kFitbitUserProfileHeightKey];
        user.heightUnit = [userDictionary objectForKey:kFitbitUserProfileHeightUnitKey];
        user.encodedId = [userDictionary objectForKey:kFitbitUserProfileEncodedIdKey];
    }
    NSLog(@"The user : %@", user);
    
    return user;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"\nFitbit User : Name=%@", self.displayName];
}


@end
