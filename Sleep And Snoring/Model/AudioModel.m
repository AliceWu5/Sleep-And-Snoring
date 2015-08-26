//
//  SnoringModel.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/23.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "AudioModel.h"
#import "StringConverter.h"
#import "CorePlot-CocoaTouch.h"

@interface AudioModel ()
@property (nonatomic, strong) NSString *audioFilePath;

@end
@implementation AudioModel


-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+(AudioModel *)shareInstance {
    AudioModel *model = [[AudioModel alloc] init];
    return model;
}

-(NSArray *)getAllAudioFiles {
    // discovery all the files in Documents/snore
    NSMutableArray *allFiles = [[NSMutableArray alloc] init];
    NSString *folderPath = [AudioModel audioFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString *fileName in files) {
            [allFiles addObject:[folderPath stringByAppendingPathComponent:fileName]];
        }
    }
    
    return allFiles;
}

-(NSString *)audioFilePath {
    if (!_audioFilePath) {
        [AudioModel audioFilePath];
    }
    return _audioFilePath;
}

-(NSArray *)getAudioByDate:(NSDate *)date {
    NSString *dateKey = [StringConverter convertDateToString:date];
    NSMutableArray *allFiles = [[NSMutableArray alloc] init];
    NSString *folderPath = [AudioModel audioFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString *fileName in files) {
            if ([fileName rangeOfString:dateKey].location == NSNotFound) {
                NSLog(@"Cannot find audio file");
            } else {
                NSLog(@"Audio file found.");
                [allFiles addObject:[folderPath stringByAppendingPathComponent:fileName]];
            }
        }
    }
    NSArray *audioData = [[NSArray alloc] init];
    if ([allFiles count]) {
        for (NSString *file in allFiles) {
            NSArray *temp = [NSArray arrayWithContentsOfFile:file];
            audioData = [audioData arrayByAddingObjectsFromArray:temp];
        }
    }
    NSLog(@"%@", audioData);
    return audioData;
}

+(NSArray *)getDataForPlotFromAudioData:(NSArray *)audioData {
    NSMutableArray *dataForPlot = [[NSMutableArray alloc] init];
    
    for (NSDictionary *record in audioData) {
        
        // for each section in the audio data
        
        NSString *timeString = record[@"time"];
        NSTimeInterval xVal = [StringConverter convertStringToTimeIntervalFrom:timeString];
        float yVal = ((NSString *)record[@"value"]).floatValue;
        
        [dataForPlot addObject:@{
                                 @(CPTScatterPlotFieldX): @(xVal),
                                 @(CPTScatterPlotFieldY): @(yVal)
                                 }
         ];
        
    }
    return  dataForPlot;
}


+ (NSString *)audioFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audioFilePath = [documentsDirectory stringByAppendingPathComponent:@"/audio"];
    
    // create folder if folder not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:audioFilePath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    return audioFilePath;
}

@end
