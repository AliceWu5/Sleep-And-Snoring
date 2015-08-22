//
//  AudioRecorder.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/21.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "AudioManager.h"


@implementation AudioManager

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(BOOL)startRecording {
    
    if (!self.recorder.recording) {
        
        //[self deleteAllFiles];
        
        NSString *docsDirectory = [self getDocumentsDirectory];
        NSString *folderPath = [docsDirectory stringByAppendingPathComponent:@"/snore"];
        
        // create folder if folder not exist
        if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
        // set format to be .caf
        NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@.caf",folderPath,[self makeFilenameFromNow]];
        
        NSURL *audioFileURL = [NSURL URLWithString:audioFilePath];
        
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16],
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
        NSError *error = nil;
        
        // init recorder everytime I want to record
        self.recorder = [[AVAudioRecorder alloc] initWithURL:audioFileURL
                                                     settings:recordSettings
                                                        error:&error];
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            return NO;
        } else {
            [self.recorder prepareToRecord];
            [self.recorder record];
        }
    } else {
        NSLog(@"From manager : Audio is recording");
        return NO;
    }
    return YES;
}

-(void)stopRecording {
    
    // stop recording and save the file
    [self.recorder stop];
    self.isRecording = NO;
    NSLog(@"The file recorded : %@", self.recorder.url);
}

#pragma mark accessor

-(void)deleteAllFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [self getDocumentsDirectory];
                           //stringByAppendingPathComponent:@"Photos/"];
    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}

-(NSString *)getDocumentsDirectory {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory = dirPaths[0];
    return docsDirectory;
}


-(NSString*)makeFilenameFromNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    // note that HH gives us 24 hour clock
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    // add a prefix
    return [NSString stringWithFormat:@"snore%@",dateString];
}


@end
