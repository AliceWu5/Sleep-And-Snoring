//
//  SleepScatterPlotController.h
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/16.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface SleepScatterPlotController : UIViewController<CPTPlotDataSource, CPTAxisDelegate, CPTPlotSpaceDelegate>
@property (nonatomic, readwrite, strong) NSArray *sleepDataForPlot;
@property (nonatomic, readwrite, strong) NSArray *heartRateDataForPlot;
@property (nonatomic, readwrite, strong) NSArray *audioDataForPlot;
@end
