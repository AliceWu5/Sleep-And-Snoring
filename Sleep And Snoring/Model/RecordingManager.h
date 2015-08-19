//
//  RecordingManager.h
//  SnoreStreamer
//
//  Created by Guy Brown on 20/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

// local constant declarations

#define NUM_BUFFERS 3
#define BUFFER_SIZE_SEC 5
#define BLOCKS_PER_FILE 29 // this gives two minute blocks

// A structure that defines the recording state

typedef struct {
    AudioStreamBasicDescription  dataFormat;
    AudioQueueRef                queue;
    AudioQueueBufferRef          buffers[NUM_BUFFERS];
    AudioFileID                  audioFile;
    SInt64                       currentPacket;
    void                         *manager;
} RecordState;

@interface RecordingManager : NSObject {
    RecordState recordState;
    AudioQueueLevelMeterState *meterLevel;
}

@property (strong) NSMutableArray *queue;
@property (assign) BOOL currentlyRecording;
@property (strong) NSString* currentFilename;
@property (strong) NSString* sessionFilename;
@property (assign) NSUInteger blockNumber;
@property (assign) int bufferCount;

-(NSString*)contentsOfQueue;

-(void)emptyQueue;

-(BOOL)startRecording;

-(void)stopRecording;

-(float)getNormalisedSoundLevel;

@end
