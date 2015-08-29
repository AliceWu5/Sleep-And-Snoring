//
//  AudioRecorder.h
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/21.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// user defaults storing key
static NSString *const kUserDefaultsAudioKey    = @"com.sleepandsnoring.audio";


@interface AudioRecorder : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic)AVAudioPlayer *player;
@property (assign)BOOL isRecording;

-(BOOL)startRecording;
-(void)stopRecording;
-(float)getSoundLevel;
-(NSTimeInterval)getRecordingTime;

@end
