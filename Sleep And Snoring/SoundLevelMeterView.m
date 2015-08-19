//
//  SoundLevelMeterView.m
//  SnoreRecorder
//
//  Created by Guy Brown on 05/03/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "SoundLevelMeterView.h"
#import "Constants.h"

@implementation SoundLevelMeterView

-(void)setup
{
    self.level = 0;
    self.segment = [NSMutableArray arrayWithCapacity:METER_NUM_SEGMENTS];
    self.backgroundColor = [UIColor clearColor];
    self.onColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.offColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    for (int i=0; i<METER_NUM_SEGMENTS; i++) {
        UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(i*(METER_SEGMENT_GAP+METER_SEGMENT_WIDTH),0,METER_SEGMENT_WIDTH,METER_SEGMENT_HEIGHT)];
        self.segment[i] = segmentView;
        [self addSubview:segmentView];
    }
}

-(float)getLevel {
    return self.level;
}

-(void)setLevel:(float)level {
    _level = level;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    int cutoff = (int)(self.level*METER_NUM_SEGMENTS);
    for (int i=0; i<cutoff; i++)
        ((UIView*)self.segment[i]).backgroundColor = self.onColor;
    for (int i=cutoff; i<METER_NUM_SEGMENTS; i++) {
        ((UIView*)self.segment[i]).backgroundColor = self.offColor;
    }
}


@end
