//
//  AudioRecorder.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/21.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager



-(BOOL)startRecording {
    
    if (!self.recorder.recording) {
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDirectory = dirPaths[0];
        
        NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@.wav",docsDirectory,[self makeFilenameFromNow]];
                                   
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
        NSLog(@"%@", audioFilePath);
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

        [session setActive:YES error:nil];
        
        [self.recorder record];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:audioFileURL
                          settings:recordSettings
                          error:&error];
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            return NO;
        } else {
            [self.recorder prepareToRecord];
        }
    }
    return YES;
}

-(void)stopRecording {
    
}

#pragma mark accessor


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
