//
//  SnoringModel.h
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/8/23.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kAudioFileName    = @"AudioModel";

@interface AudioModel : NSObject

+(AudioModel *)shareInstance;
+(NSString *)audioFilePath;
+(NSArray *)getDataForPlotFromAudioData:(NSArray *)audioData;

-(NSArray *)getAudioByDate:(NSDate *)date;
-(NSArray *)getAllAudioFiles;
@end
