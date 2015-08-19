//
//  Constants.m
//  SnoreStreamer
//
//  Created by Guy Brown on 16/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

// URL of the server

//NSString* const SERVER_URL = @"http://hearing.rcweb.dcs.shef.ac.uk/snoring/";
NSString* const SERVER_URL = @"http://snoring.rcweb.dcs.shef.ac.uk/foghorn/";

// salt for md5 hashing of password

NSString* const PASSWORD_SALT = @"sl3EpAppn03A";

// time for a recording block

int const BLOCK_SIZE_SEC = 120;

// prefix for filenames (can be set to null)

NSString* const FILENAME_PREFIX = @"";

// upload in progress

NSString* const UPLOAD_PROGRESS = @"Upload in progress...";

// upload completed

NSString* const UPLOAD_COMPLETED = @"Completed";

// upload ok but couldn't delete local file for some reason

NSString* const UPLOADED_NOT_DELETED = @"Uploaded but couldn't delete local file";

// upload failed so we will retry

NSString* const UPLOAD_RETRYING = @"Upload failed, retrying...";

// upload failed due to server error

NSString* const UPLOAD_FAILED = @"Upload failed due to server error";

// default sample rate

float const DEFAULT_SAMPLE_RATE = 16000.0;

// default sample rate control index (tied to default sample rate)

int const DEFAULT_SAMPLE_RATE_SEGMENT = 1;

// is the settings tab enabled?

bool const SETTINGS_ENABLED = NO;

// sound level meter - number of segments

int const METER_NUM_SEGMENTS = 48;

// sound level meter - segment width

int const METER_SEGMENT_WIDTH = 4;

// sound level meter - segment height

int const METER_SEGMENT_HEIGHT = 25;

// sound level meter - segment gap

int const METER_SEGMENT_GAP = 2;

// brightness level

float const DIMMED_BRIGHTNESS = 0.0; // change to 0.0 for general use

// maximum number of upload attempts

int const MAX_NUMBER_OF_UPLOAD_ATTEMPTS = 3;

// name of this service, for the keychain

NSString* const SERVICE_NAME = @"SleepAppnoea";

// the index of the settings tab bar

int const TAB_BAR_INDEX = 3;


