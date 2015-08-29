//
//  AudioRecorder.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/21.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "AudioRecorder.h"
#import "AudioModel.h"

@interface AudioRecorder ()
@property (strong, nonatomic)AVAudioRecorder *recorder;
@property (nonatomic, strong) NSMutableArray *audioLevels;
@property (nonatomic, strong)NSString *startTimeString;
@end

@implementation AudioRecorder

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(BOOL)startRecording {
    
    if (!self.isRecording) {
        // store audio in the documents directory
        NSString *docsDirectory = [self getDocumentsDirectory];
        NSString *folderPath = [docsDirectory stringByAppendingPathComponent:@"/snore"];
        
        // create folder if folder not exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
        // set audio format to be .caf
        self.startTimeString = [self makeFilenameFromNow];
        NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@.caf",folderPath, self.startTimeString];
        
        NSURL *audioFileURL = [NSURL URLWithString:audioFilePath];
        
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
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
        // set metering to YES
        self.recorder.meteringEnabled = YES;
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
            return NO;
        }
        BOOL prepared = [self.recorder prepareToRecord];
        BOOL recordStarted = [self.recorder record];
        if (prepared && recordStarted) {
            self.isRecording = YES;
            self.audioLevels = [[NSMutableArray alloc] init];
            return YES;
        }
    }
    self.isRecording = NO;
    return NO;
}

-(void)stopRecording {
    
    // stop recording and save the file
    [self.recorder stop];
    self.isRecording = NO;
    [self saveAudioLevelFile];
    [self deleteFileFromURL:self.recorder.url];
    NSLog(@"The file recorded : %@", self.recorder.url);
}

-(float)getSoundLevel
{
    float peak_level = 0.0;
    
    // if we're not currently recording, function will return zero
    if (self.isRecording) {
        
        // all this assumes that we are dealing with a single channel (we are)
        // if muliple channels, would need to allocate memory for each channel
        
        [self.recorder updateMeters];
        peak_level = 65 + [self.recorder averagePowerForChannel:0];
        
        // display the level
        NSLog(@"power level : %f", peak_level - 65);
        
        // sound between 65 and 0
        if (peak_level > 65) peak_level = 65;
        if (peak_level < 0) peak_level = 0;
        
        // store level in an array
        NSString *deviceCurrentTime = [self getCurrentTime];
        NSString *levelValue = [NSString stringWithFormat:@"%f", peak_level];

        [self.audioLevels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     deviceCurrentTime,@"time",
                                     levelValue, @"value",
                                     nil]];
    }
    peak_level = peak_level / 65.0f;
    
    return peak_level;
}

-(void)saveAudioLevelFile {
    // save array as a file and timestamp the file
    NSString *filePath = [AudioModel audioFilePath];
    filePath = [filePath stringByAppendingPathComponent:self.startTimeString];
    [self.audioLevels writeToFile:filePath atomically:YES];
    self.audioLevels = nil;
}


-(NSTimeInterval)getRecordingTime {
    NSTimeInterval duration = 0.0;
    // if not recording return zero
    if (self.isRecording) {
        duration = [self.recorder currentTime];
    }
    return duration;
}

#pragma mark accessor

-(void)deleteAllFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [self getDocumentsDirectory];

    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}

-(void)deleteFileFromURL:(NSURL *)url {
    // remove a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:nil];
}

-(NSString *)getDocumentsDirectory {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory = dirPaths[0];
    return docsDirectory;
}

-(NSString *)getCurrentTime {
    // get time including milisecond value
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss:SSS"];
    return [formatter stringFromDate:[NSDate date]];
}


-(NSString*)makeFilenameFromNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    // note that HH gives us 24 hour clock
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    // add a prefix
    return [NSString stringWithFormat:@"%@",dateString];
}


@end
