//
//  FitbitAPI.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/9.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

// standard Fitbit json keys



// Standard Fitbit User profile keys

static NSString *const kFitbitUserProfileKey                    =@"user";
static NSString *const kFitbitUserProfileAgeKey                 =@"age";
static NSString *const kFitbitUserProfilePhototKey              =@"avatar";
static NSString *const kFitbitUserProfileDateOfBirthKey         =@"dateOfBirth";
static NSString *const kFitbitUserProfileDisplayNameKey         =@"displayName";
static NSString *const kFitbitUserProfileFullNameKey            =@"fullName";
static NSString *const kFitbitUserProfileGenderKey              =@"gender";
static NSString *const kFitbitUserProfileHeightKey              =@"height";
static NSString *const kFitbitUserProfileHeightUnitKey          =@"heightUnit";
static NSString *const kFitbitUserProfileEncodedIdKey           =@"encodedId";



// Standard Fitbit Sleep data keys

static NSString *const kFitbitSleepDataKey                      = @"sleep";
static NSString *const kFitbitSleepDataAwakeCountKey            = @"awakeCount";
static NSString *const kFitbitSleepDataAwakeDurationKey         = @"awakeDuration";
static NSString *const kFitbitSleepDataAwakeningsCountKey       = @"awakeningsCount";
static NSString *const kFitbitSleepDataDateOfSleepKey           = @"dateOfSleep";
static NSString *const kFitbitSleepDataDurationKey              = @"duration";
static NSString *const kFitbitSleepDataEfficiencyKey            = @"efficiency";
static NSString *const kFitbitSleepDataIsMainSleepKey           = @"isMainSleep";
static NSString *const kFitbitSleepDataLogIdKey                 = @"logId";
static NSString *const kFitbitSleepDataMinutesAfterWakeupKey    = @"minutesAfterWakeup";
static NSString *const kFitbitSleepDataMinutesAsleepKey         = @"minutesAsleep";
static NSString *const kFitbitSleepDataMinutesAwakeKey          = @"minutesAwake";
static NSString *const kFitbitSleepDataMinutesToFallAsleepKey   = @"minutesToFallAsleep";
static NSString *const kFitbitSleepDataRestlessCountKey         = @"restlessCount";
static NSString *const kFitbitSleepDataRestlessDurationKey      = @"restlessDuration";
static NSString *const kFitbitSleepDataStartTimeKey             = @"startTime";
static NSString *const kFitbitSleepDataTimeInBedKey             = @"timeInBed";


// Standard Fitbit Sleep minutes data keys

static NSString *const kFitbitSleepDataMinuteDataKey            = @"minuteData";
static NSString *const kFitbitSleepDataMinuteDataDateTimeKey    = @"dateTime";
static NSString *const kFitbitSleepDataMinuteDataValueKey       = @"value";


// Standard Fitbit Sleep summary keys

static NSString *const kFitbitSleepSummaryKey                   = @"summary";
static NSString *const kFitbitSleepSummaryTotalMinutesAsleepKey = @"totalMinutesAsleep";
static NSString *const kFitbitSleepSummaryTotalSleepRecordsKey  = @"totalSleepRecords";
static NSString *const kFitbitSleepSummaryTotalTimeInBedKey     = @"totalTimeInBed";


// Standard Fitbit Activity keys

static NSString *const kFitbitActivitiesDistanceKey             = @"activities-distance";
static NSString *const kFitbitActivitiesDistanceDateTimeKey     = @"dateTime";
static NSString *const kFitbitActivitiesDistanceValueKey        = @"value";


@interface FitbitAPI : NSObject

@end
