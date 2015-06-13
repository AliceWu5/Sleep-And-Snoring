//
//  FitbitHeart.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/11.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FitbitActivity : NSObject


+ (FitbitActivity *)activityWithJSON:(NSDictionary *)json;

@end
