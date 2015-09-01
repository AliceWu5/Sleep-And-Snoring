//
//  Constants.h
//  SnoreStreamer
//
//  Created by Guy Brown on 16/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//


// keys for SSKeychain
static NSString *const kSleepAndSnoringService          = @"Sleep And Snoring";
static NSString *const kSleepAndSnoringAccessAccount    = @"com.sleepandsnoring.accesstoken";
static NSString *const kSleepAndSnoringRefreshAccount   = @"com.sleepandsnoring.refreshtoken";


// URL of the server

extern NSString* const SERVER_URL;

// salt for md5 hashing of password

extern NSString* const PASSWORD_SALT;

// time for a recording block

extern int const BLOCK_SIZE_SEC;

// prefix for filenames (can be set to null)

extern NSString* const FILENAME_PREFIX;

// upload in progress

extern NSString* const UPLOAD_PROGRESS;

// upload completed

extern NSString* const UPLOAD_COMPLETED;

// upload failed due to server error

extern NSString* const UPLOAD_FAILED;

// upload ok but couldn't delete local file for some reason

extern NSString* const UPLOADED_NOT_DELETED;

// upload failed so we will retry

extern NSString* const UPLOAD_RETRYING;

// default sample rate (tied to default segment value)

extern float const DEFAULT_SAMPLE_RATE;

// default sample rate control index (tied to default sample rate)

extern int const DEFAULT_SAMPLE_RATE_SEGMENT;

// is the settings tab enabled?

extern bool const SETTINGS_ENABLED;

// sound level meter - number of segments

extern int const METER_NUM_SEGMENTS;

// sound level meter - segment width

extern int const METER_SEGMENT_WIDTH;

// sound level meter - segment height

extern int const METER_SEGMENT_HEIGHT;

// sound level meter - segment gap

extern int const METER_SEGMENT_GAP;

// brightness level

extern float const DIMMED_BRIGHTNESS;

// maximum number of upload attempts

extern int const MAX_NUMBER_OF_UPLOAD_ATTEMPTS;

// name of this service, for the keychain

extern NSString* const SERVICE_NAME;

// the index of the settings tab bar

extern int const TAB_BAR_INDEX;



