//
//  Model.m
//  SnoreStreamer
//
//  Created by Guy Brown on 14/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "Model.h"
#import "Constants.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation Model

static Model *modelInstance = nil;

+(Model*)sharedInstance
{
    if (modelInstance==nil) {
        modelInstance = [[super alloc]init];
        modelInstance.isRecording = NO;
        modelInstance.nameOfCurrentRecording = @"NO_CURRENT_RECORDING";
        modelInstance.sampleRate = DEFAULT_SAMPLE_RATE;
        modelInstance.items = [[NSMutableArray alloc]initWithCapacity:100];
        modelInstance.log = [NSMutableString stringWithString:@""];
        modelInstance.brightness = [UIScreen mainScreen].brightness;
        modelInstance.gainChangeIsEnabled = NO;
        modelInstance.currentlyLoggedIn = NO;
        modelInstance.username = @"";
        modelInstance.safeMode = YES; // start with safe mode on
        modelInstance.dimmingEnabled = YES; // start with dimming enabled
        // make a json string containing the device information
        NSString *version = [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
        // get the model name, this is a bit of a hack
        struct utsname systeminfo;
        uname(&systeminfo);
        NSString *devicename = [NSString stringWithCString:systeminfo.machine encoding:NSUTF8StringEncoding];
        modelInstance.deviceinfo = [NSString stringWithFormat:@"{\"version\":\"%@\",\"devicename\":\"%@\"}",version,devicename];
    }
    return modelInstance;
}

-(void)clearLog
{
    [self.log setString:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_SETTINGS" object:nil];
}

-(void)clearUploadTable
{
    [self.items removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_TABLE" object:nil];
}



-(void)writeToLog:(NSString *)str
{
    [self.log appendString:[NSString stringWithFormat:@"\n%@",str]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_SETTINGS" object:nil];
}

-(NSString*)getLogString
{
    return [self.log description];
}

@end
