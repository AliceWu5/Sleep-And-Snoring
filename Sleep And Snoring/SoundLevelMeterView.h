//
//  SoundLevelMeterView.h
//  SnoreRecorder
//
//  Created by Guy Brown on 05/03/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundLevelMeterView : UIView

@property (strong) NSMutableArray *segment;
@property (assign,nonatomic) float level;
@property (strong) UIColor* onColor;
@property (strong) UIColor* offColor;

-(void)setup;

@end
