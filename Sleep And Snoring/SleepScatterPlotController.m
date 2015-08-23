//
//  SleepScatterPlotController.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/16.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "SleepScatterPlotController.h"

static NSTimeInterval const oneHour = 60*60;


@interface SleepScatterPlotController ()
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, strong)CPTGraphHostingView *hostingView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;
@end

@implementation SleepScatterPlotController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add tap gesture to dismiss view controller
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(responseToTapGesture)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapGesture];
    
    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:self.view.frame];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.graph = newGraph;

    self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    self.hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    self.hostingView.hostedGraph     = newGraph;
    
    newGraph.paddingLeft   = 10.0;
    newGraph.paddingTop    = 10.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 10.0;
    
    [self.view addSubview:self.hostingView];
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    
    // should allow user interaction
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(12.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-100.0) length:CPTDecimalFromDouble(300.0)];
    plotSpace.delegate = self;
    
    // customized x axis
    [self configureXAxisForGraph:newGraph];
    [self configureYAxisForGraph:newGraph];
    
    // create a audio plot area
    CPTScatterPlot *audioPlot = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    audioPlot.dataLineStyle = lineStyle;
    audioPlot.identifier    = @"Audio Plot";
    audioPlot.dataSource    = self;
    [newGraph addPlot:audioPlot];
    
    // Put an area gradient under the plot above
    CPTColor *audioColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(0.3) blue:CPTFloat(1.0) alpha:CPTFloat(0.8)];
    CPTGradient *audioGradient = [CPTGradient gradientWithBeginningColor:audioColor endingColor:[CPTColor clearColor]];
    audioGradient.angle = -90.0;
    CPTFill *audioGradientFill = [CPTFill fillWithGradient:audioGradient];
    audioPlot.areaFill      = audioGradientFill;
    audioPlot.areaBaseValue = CPTDecimalFromDouble(130);
    
    // Create a sleep plot area
    CPTScatterPlot *sleepPlot  = [[CPTScatterPlot alloc] init];
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor orangeColor];
    sleepPlot.dataLineStyle = lineStyle;
    sleepPlot.identifier    = @"Sleep Plot";
    sleepPlot.dataSource    = self;
    [newGraph addPlot:sleepPlot];
    
    // Put an area gradient under the plot above
    CPTGradient *orangeGradient = [CPTGradient gradientWithBeginningColor:[CPTColor orangeColor] endingColor:[CPTColor clearColor]];
    orangeGradient.angle = -90.0;
    CPTFill *orangeAreaGradientFill = [CPTFill fillWithGradient:orangeGradient];
    //CPTFill *areaOrangeFill = [CPTFill fillWithGradient:orangeGradient];
    sleepPlot.areaFill      = orangeAreaGradientFill;
    sleepPlot.areaBaseValue = CPTDecimalFromDouble(-90.0);
    
    // Create a heart rate plot area
    CPTScatterPlot *heartRatePlot = [[CPTScatterPlot alloc] init];
    lineStyle                        = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    heartRatePlot.dataLineStyle = lineStyle;
    heartRatePlot.identifier    = @"Heart Rate Plot";
    heartRatePlot.dataSource    = self;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    heartRatePlot.areaFill      = areaGradientFill;
    heartRatePlot.areaBaseValue = CPTDecimalFromDouble(1.75);
    
    // Animate in the new plot, as an example
    heartRatePlot.opacity = 0.0;
    [newGraph addPlot:heartRatePlot];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0;
    [sleepPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    [heartRatePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}

-(void)configureYAxisForGraph:(CPTGraph*)graph{
    
    CPTMutableTextStyle *majorTextStyle = [CPTMutableTextStyle textStyle];
    majorTextStyle.color = [CPTColor whiteColor];
    majorTextStyle.fontName = @"Helvetica-Bold";
    majorTextStyle.fontSize = 10.0f;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:60.0];
    y.delegate             = self;
    y.tickDirection = CPTSignPositive;
    y.tickLabelDirection = CPTSignPositive;
    y.labelAlignment = CPTAlignmentRight;
    y.labelOffset = -55.0f;
    
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = @[@-90, @-60, @-30, @0, @15, @30, @45, @60, @75, @90];
    NSArray *yAxisLabels = @[@"Asleep", @"Restless", @"Awake",@"", @"40", @"55",@"70",@"85", @"100", @"115"];
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[yAxisLabels count]];
    
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [yAxisLabels objectAtIndex:labelLocation++] textStyle:majorTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = y.labelOffset + y.majorTickLength;
        newLabel.rotation = 0;
        [customLabels addObject:newLabel];
    }
    y.axisLabels =  [NSSet setWithArray:customLabels];
    axisSet.yAxis.majorTickLocations = [NSSet setWithArray:customTickLocations];
    
}

-(void)configureXAxisForGraph:(CPTGraph*)graph{
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTPlotRange *xAxisRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromString(@"0.0") length:CPTDecimalFromString(@"24.0")];

    CPTMutableTextStyle *majorTextStyle = [CPTMutableTextStyle textStyle];
    majorTextStyle.color = [CPTColor whiteColor];
    majorTextStyle.fontName = @"Helvetica-Bold";
    majorTextStyle.fontSize = 10.0f;
    
    x.majorIntervalLength = CPTDecimalFromDouble(6.0);
    x.minorTickLength = 3.0f;
    x.visibleRange = xAxisRange;
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //x.title = @"Hours";
    x.titleTextStyle = majorTextStyle;
    x.titleOffset = 30.0f;
    x.labelRotation = M_PI/8;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.tickDirection = CPTSignNone;
    x.tickLabelDirection = CPTSignNegative;
    NSArray *customTickLocations = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13,
                                    @14, @15, @16, @17, @18, @19, @20, @21, @22, @23];
    
    NSArray *xAxisLabels = @[@"0 AM", @"1 AM", @"2 AM", @"3 AM", @"4 AM", @"5 AM",@"6 AM",@"7 AM", @"8 AM",@"9 AM", @"10 AM", @"11 AM", @"12 PM", @"1 PM", @"2 PM",@"3 PM",@"4 PM", @"5 PM", @"6 PM", @"7 PM", @"8 PM", @"9 PM", @"10PM", @"11PM"];
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:majorTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = x.labelOffset + x.majorTickLength;
        newLabel.rotation = M_PI/8;
        [customLabels addObject:newLabel];
    }
    x.axisLabels =  [NSSet setWithArray:customLabels];
    axisSet.xAxis.majorTickLocations = [NSSet setWithArray:customTickLocations];
    axisSet.xAxis.minorTickLocations = [NSSet setWithArray:customTickLocations];
}


// set landscape only
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate {
    return YES;
}


-(void)viewDidLayoutSubviews {
    [self.hostingView setFrame:[self.view bounds]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setOrientation:(UIInterfaceOrientation)orientation {
    NSNumber *value = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromDouble(3.0 + 2.0 * arc4random() / UINT32_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromDouble(3.0 + 2.0 * arc4random() / UINT32_MAX)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([(NSString *)plot.identifier isEqualToString:@"Sleep Plot"]) {
        return [self.sleepDataForPlot count];
    } else if ([(NSString *)plot.identifier isEqualToString:@"Heart Rate Plot"]){
        return [self.heartRateDataForPlot count];
    } else if ([(NSString *)plot.identifier isEqualToString:@"Audio Plot"]) {
        return [self.audioDataForPlot count];
    }
    return 0;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    /*
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.dataForPlot[index][key];
    //NSLog(@"The num is : %@", self.dataForPlot);
    // Green plot gets shifted above cvfvgthe blue
    if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
        if ( fieldEnum == CPTScatterPlotFieldY ) {
            num = @([num doubleValue] + 1.0);
        }
    }
    return num;
     */
    NSNumber *value = nil;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX: {
            
            if ([(NSString *)plot.identifier isEqualToString:@"Sleep Plot"]) {
                NSTimeInterval time = ((NSNumber *)self.sleepDataForPlot[index][@(fieldEnum)]).doubleValue;
                value = [NSNumber numberWithDouble:time / oneHour];
            } else if ([(NSString *)plot.identifier isEqualToString:@"Heart Rate Plot"]){
                // heart rate plot
                NSTimeInterval time = ((NSNumber *)self.heartRateDataForPlot[index][@(fieldEnum)]).doubleValue;
                value = [NSNumber numberWithDouble:time / oneHour];
            } else if ([(NSString *)plot.identifier isEqualToString:@"Audio Plot"]) {
                NSTimeInterval time = ((NSNumber *)self.audioDataForPlot[index][@(fieldEnum)]).doubleValue;
                value = [NSNumber numberWithDouble:time / oneHour];

            }
            break;
        }
            
        case CPTScatterPlotFieldY: {
            if ([(NSString *)plot.identifier isEqualToString:@"Sleep Plot"]) {
                int sleepValue = ((NSNumber *)self.sleepDataForPlot[index][@(fieldEnum)]).intValue;
                value = [NSNumber numberWithInt:sleepValue * 30 - 120];
            } else if ([(NSString *)plot.identifier isEqualToString:@"Heart Rate Plot"]){
                // heart rate plot
                int heartRate = ((NSNumber *)self.heartRateDataForPlot[index][@(fieldEnum)]).intValue;
                value = [NSNumber numberWithDouble:heartRate - 25];
            } else if ([(NSString *)plot.identifier isEqualToString:@"Audio Plot"]) {
                float audioLevel = ((NSNumber *)self.audioDataForPlot[index][@(fieldEnum)]).floatValue;
                value = [NSNumber numberWithFloat:audioLevel + 130.0f];
            }
            break;
        }
    }
    return value;
}



#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle  = nil;
    static CPTTextStyle *negativeStyle  = nil;
    static dispatch_once_t positiveOnce = 0;
    static dispatch_once_t negativeOnce = 0;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            dispatch_once(&positiveOnce, ^{
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle = newStyle;
            });
            
            theLabelTextStyle = positiveStyle;
        }
        else {
            dispatch_once(&negativeOnce, ^{
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle = newStyle;
            });
            
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    return NO;
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space
     willChangePlotRangeTo:(CPTPlotRange *)newRange
             forCoordinate:(CPTCoordinate)coordinate {
    CPTPlotRange *updatedRange = nil;

    switch ( coordinate ) {
        case CPTCoordinateX:
            if (newRange.locationDouble < - 3.0) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromDouble(-3.0);
                updatedRange = mutableRange;
            } else if (newRange.locationDouble > 13.0 ) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromDouble(13.0);
                updatedRange = mutableRange;
            }
            else {
                updatedRange = newRange;
            }
            updatedRange = newRange;
            break;
        case CPTCoordinateY:
            updatedRange = ((CPTXYPlotSpace *)space).yRange;
            break;
    }
    return updatedRange;
}


#pragma mark override
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        //NSLog(@"%@", orientation);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"The bounds : %@", NSStringFromCGRect([self.view bounds]));

        [self.hostingView setFrame:[self.view bounds]];
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}



#pragma mark Gesture response

- (void)responseToTapGesture {
    NSLog(@"Dissmiss Plot View.");
    [self dismissViewControllerAnimated:YES completion:^{
       // to do
    }];
}

@end
