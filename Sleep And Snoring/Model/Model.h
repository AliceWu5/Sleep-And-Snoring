//
//  Model.h
//  SnoreStreamer
//
//  Created by Guy Brown on 14/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

// because we need to communicate with the model across a lot of view controllers
// and other classes, it has been implemented as a singleton

@interface Model : NSObject

@property (assign) BOOL isRecording;
@property (strong) NSString *nameOfCurrentRecording;
@property (assign) float sampleRate;
@property (strong) NSMutableArray *items;   // for the upload table
@property (strong) NSMutableString *log;    // for the log in the settings panel
@property (assign) float brightness;      // cache the screen brightness
@property (strong) NSDate *timeRecordingStarted; // time that recording started
@property (assign) BOOL gainChangeIsEnabled;
@property (assign) BOOL currentlyLoggedIn;
@property (strong) NSString *username;
@property (strong) NSString *deviceinfo;
@property (assign) BOOL safeMode;
@property (assign) BOOL dimmingEnabled;
@property (assign) BOOL isMale;

+(Model*)sharedInstance;

-(void)clearUploadTable;

-(void)clearLog;

-(void)writeToLog:(NSString*)str;

-(NSString*)getLogString;

@end
