//
//  RecordingManager.m
//  SnoreStreamer
//
//  Created by Guy Brown on 20/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "RecordingManager.h"
#import "Constants.h"
#import "Model.h"

@implementation RecordingManager

-(id)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSMutableArray alloc]initWithCapacity:20];
        self.currentlyRecording = NO;
        meterLevel = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState));
    }
    return self;
}

-(NSString*)contentsOfQueue
{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (int i=0; i<[self.queue count]; i++) {
        //UploadManager *m = (UploadManager*)self.queue[i];
        //[str appendFormat:@"[%02d] : %@",i,m.filename];
    }
    return str;
}

-(void)emptyQueue
{
    [self.queue removeAllObjects];
}

// set up the audio format for WAV file
// 16 bits per channel
// for a mono file, a "frame" is the same as a "packet"
// note that this is really a C function that operates on a C structure

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
    format->mSampleRate = [Model sharedInstance].sampleRate;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFramesPerPacket = 1;
    format->mChannelsPerFrame = 1;
    format->mBytesPerFrame = 2;
    format->mBytesPerPacket = 2;
    format->mBitsPerChannel = 16;
    format->mReserved = 0;
    format->mFormatFlags = kAudioFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
}

-(BOOL)startRecording
{
    Model *model = [Model sharedInstance];
    if (model.currentlyLoggedIn==NO)
        return false;
    
    // display the device information
    
    [model writeToLog:model.deviceinfo];
    
    // now start the recording
    
    [model writeToLog:@"RecordingManager: started recording"];
    self.blockNumber=0;
    self.currentFilename = nil;
    self.sessionFilename = [self makeFilenameFromNow];
    model.nameOfCurrentRecording = self.sessionFilename; // used for writing demographics
    self.currentlyRecording = YES;
    [self setupAudioFormat:&recordState.dataFormat];
    recordState.currentPacket = 0;
    self.bufferCount = 0;
    self.blockNumber = 1;

    // we need to refer to objective-C objects in the C callback function
    // so we pass the current object (self) as user data, but ARC won't allow the
    // direct assignment so it has to be a bridged void pointer
    
    recordState.manager = (__bridge void*)self;

    // the filename that we are writing to
    // this needs to be bridged to a core foundation URL reference
    
    self.currentFilename = [NSString stringWithFormat:@"%@-%03lu",self.sessionFilename,(unsigned long)self.blockNumber];
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],self.currentFilename,nil];;
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPathComponents:pathComponents];

    // open an audio input to the double buffer
    
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    // check that everything went OK and we can record
    
    if (status==0) {
        
        // Prime recording buffers with empty data
        // we let each buffer contain 5 seconds of audio
        
        for (int i=0; i<NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(recordState.queue,((int)[Model sharedInstance].sampleRate)*2*BUFFER_SIZE_SEC, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer (recordState.queue, recordState.buffers[i], 0, NULL);
        }
        
        // make the file to record the audio queue to
        
        status = AudioFileCreateWithURL(url,
                                        kAudioFileWAVEType,
                                        &recordState.dataFormat,
                                        kAudioFileFlags_EraseFile,
                                        &recordState.audioFile);
        
        // check that the file was created OK
        // this might go wrong if we are out of memory or the file specification is wrong
        // if OK, start recording to the audio queue
        
        /*
         In principle this should modify the metadata in the file, but it doesn't work
         Seems that iOS doesn't support property changes to ID3 info dictionary
         
        if (status==0) {
            // try to add metadata to the audio file so that we embed the device type
            CFDictionaryRef fileDict = nil;
            UInt32 size = sizeof(fileDict);
            OSStatus err = AudioFileGetProperty(recordState.audioFile, kAudioFilePropertyInfoDictionary, &size, &fileDict);
            if (err == noErr) {
                NSDictionary* dict = (__bridge NSDictionary*) fileDict;
                NSLog(@"%@",dict);
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
                [newDict addEntriesFromDictionary:dict];
                [newDict setObject:@"iPod Touch" forKey:[NSString stringWithUTF8String:kAFInfoDictionary_Comments]];
                err = AudioFileSetProperty(recordState.audioFile, kAudioFilePropertyInfoDictionary, size, (__bridge const void *)(newDict));
                if (err!=noErr) {
                    NSLog(@"Could not write to dictionary");
                }
            }
        }
         */
        
        // since we can't put information in the file, send the metadata to the server
        // as a little bit of JSON
        
        if (status==0)
            status = AudioQueueStart(recordState.queue, NULL);
        
    }
    
    // try to enable level metering
    
    if (status==0) {
        UInt32 val = 1;
        status = AudioQueueSetProperty(recordState.queue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
        if (status!=0) {
            [model writeToLog:@"RecordingManager: Could not enable level metering"];
        }
    }
    
    // things could have gone wrong, in which case stop recording
    
    if (status!=0) {
        [model writeToLog:@"RecordingManager: Recording failed"];
        [self stopRecording];
        return NO;
    }
    
    return YES;
}

// this is a C function that writes a full audio queue to the file
// the tricky thing here is that we are buffering in stages; when we've
// filled a file with two minutes worth of audio we start uploading it to the
// server and switch to filling another file

void AudioInputCallback(void *inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp *inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription *inPacketDescs)
{
    // get the user data
    
    RecordState *recordState = (RecordState*)inUserData;
    
    // get the objective-C object corresponding to self
    
    RecordingManager *manager = (__bridge RecordingManager*)recordState->manager;
    
    // if we are not currently recording then we shouldn't be here, so leave!
    
    if (!manager.currentlyRecording) return;
    
    // write the audio frames (packets) to the file
    
    OSStatus status = AudioFileWritePackets(recordState->audioFile,
                                            false,
                                            inBuffer->mAudioDataByteSize,
                                            inPacketDescs,
                                            recordState->currentPacket,
                                            &inNumberPacketDescriptions,
                                            inBuffer->mAudioData);
    
    if (status==0)
    {
        // keep track of the number of frames that we have written
        
        recordState->currentPacket += inNumberPacketDescriptions;
        
        // we wrote a full buffer (one block of 5 seconds) so increment the block count
        
        manager.bufferCount++;
        
        // have we filled a 2-minute file? if so, we need to start filling a different file
        
        if (manager.bufferCount>BLOCKS_PER_FILE) {
            
            AudioFileClose(recordState->audioFile);
            manager.bufferCount = 0;
            
            // upload this file
            
            //UploadManager *uploader = [[UploadManager alloc]initWithFilename:manager.currentFilename delegate:manager];
            
            // add to the upload queue
            
            //[manager.queue addObject:uploader];
            
            // so we can keep track of it, add to the log table too
            
            //[[Model sharedInstance] addUpload:uploader];
            
            // start the upload
            
            //[uploader start];
           
            // add one to the block count and make the next file name
            
            manager.blockNumber++;
            manager.currentFilename = [NSString stringWithFormat:@"%@-%03lu",manager.sessionFilename,(unsigned long)manager.blockNumber];
            NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],manager.currentFilename,nil];;
            CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPathComponents:pathComponents];
            
            // in the new file we start at frame (packet) zero
            
            recordState->currentPacket=0;
            
            // try to create the new file
            
            status = AudioFileCreateWithURL(url,
                                            kAudioFileWAVEType,
                                            &recordState->dataFormat,
                                            kAudioFileFlags_EraseFile,
                                            &recordState->audioFile);
            
        }
    }
    
    // are things working out? if not we should probably stop recording at this point
    
    if (status!=0) {
        [[Model sharedInstance] writeToLog:@"Some problem - unable to write to file or create a new file"];
    }
    
    // put the empty buffer back in the queue
    
    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
    
}

-(void)stopRecording
{
    // stop recording
    
    self.currentlyRecording = NO;
    [[Model sharedInstance] writeToLog:@"RecordingManager: stopped recording"];
    AudioQueueStop(recordState.queue, true);
    
    // empty the buffers and dispose of them
    
    for (int i=0; i<NUM_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    AudioQueueDispose(recordState.queue, true);
    
    // close the last file
    
    AudioFileClose(recordState.audioFile);
    
    // upload whatever we got in the last file
    
    if (self.currentFilename) {
        //UploadManager *uploader = [[UploadManager alloc]initWithFilename:self.currentFilename delegate:self];
        // add to the upload queue
        //[self.queue addObject:uploader];
        // so we can keep track of it, add to the log table too
        //[[Model sharedInstance] addUpload:uploader];
        // start the upload
        //[uploader start];
        // no more files to come, so set current filename to nil
        self.currentFilename = nil;
    }
}

-(float)getNormalisedSoundLevel
{
    
    float norm_peak_level = 0.0;
    
    // if we're not currently recording, function will return zero
    
    if (self.currentlyRecording) {
        
        // all this assumes that we are dealing with a single channel (we are)
        // if muliple channels, would need to allocate memory for each channel
        
        UInt32 meterDataSize = sizeof(AudioQueueLevelMeterState);
        OSErr status = AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeterDB, meterLevel, &meterDataSize);
        
        // did we get the level information?
        
        if (status==0) {
            
            // get the meter value
            
            float db = meterLevel->mPeakPower;
            
            // just in case we get something really loud or really quiet
            
            if (db>0) db=0;
            if (db<-40) db=-40;
            
            // range is now -40 dB to 0 dB, map to range [0,1]
            
            norm_peak_level = (db+40.0)/40.0;
        }
    }
    return norm_peak_level;
}

-(NSString*)makeFilenameFromNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    // note that HH gives us 24 hour clock
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    // add a prefix
    return [NSString stringWithFormat:@"%@%@",FILENAME_PREFIX,dateString];
}

//-(void)removeUploaderFromQueue:(UploadManager *)uploader
//{
//    // remove the object from the queue
//    [[Model sharedInstance] writeToLog:[NSString stringWithFormat:@"removing object %@ from queue",uploader.filename]];
//    [self.queue removeObjectIdenticalTo:uploader];
//    // now uploaded, so delete this file from the documents directory
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [docPaths objectAtIndex:0];
//    NSString *filePath = [path stringByAppendingPathComponent:uploader.filename];
//    NSError *error = nil;
//    BOOL ok = [fm removeItemAtPath:filePath error:&error];
//    if (!ok) {
//        uploader.statusString = UPLOADED_NOT_DELETED;
//        NSLog(@"Unsuccessfully attempted to remove %@: %@",filePath,[error localizedDescription]);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_SETTINGS" object:nil];
//    }
//    // since the subtitle of the table cell will have changed, update the table
//    // broadcast a notification
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_TABLE" object:nil];
//}

-(void) dealloc {
    // ARC will take care of everything except this
    free(meterLevel);
}

@end
