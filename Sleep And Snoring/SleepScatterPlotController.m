//
//  SleepScatterPlotController.m
//  Sleep And Snoring
//
//  Created by Jiao Liu on 15/6/16.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "SleepScatterPlotController.h"

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
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
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
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5) length:CPTDecimalFromDouble(4.0)];
    plotSpace.delegate = self;
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
//    CPTXYAxis *x          = axisSet.xAxis;
//    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
//    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
//    x.minorTicksPerInterval       = 2;
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.99) length:CPTDecimalFromDouble(0.02)]];
//    x.labelExclusionRanges = exclusionRanges;
    
    // customized x axis
    [self configureXAxisForGraph:newGraph];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    exclusionRanges               = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(3.99) length:CPTDecimalFromDouble(0.02)]];
    y.labelExclusionRanges = exclusionRanges;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:30.0];
    y.delegate             = self;
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor cyanColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier    = @"Sleep Plot";
    boundLinePlot.dataSource    = self;
    [newGraph addPlot:boundLinePlot];
    
//    CPTImage *fillImage = [CPTImage imageNamed:@"BlueTexture"];
//    fillImage.tiled = YES;
//    CPTFill *areaImageFill = [CPTFill fillWithImage:fillImage];
//    boundLinePlot.areaFill      = areaImageFill;
//    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(1.0, 1.0);
    boundLinePlot.plotSymbol = plotSymbol;
    
//    // Create a green plot area
//    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
//    lineStyle                        = [CPTMutableLineStyle lineStyle];
//    lineStyle.lineWidth              = 3.0;
//    lineStyle.lineColor              = [CPTColor greenColor];
//    lineStyle.dashPattern            = @[@5.0, @5.0];
//    dataSourceLinePlot.dataLineStyle = lineStyle;
//    dataSourceLinePlot.identifier    = @"Green Plot";
//    dataSourceLinePlot.dataSource    = self;
//    
//    // Put an area gradient under the plot above
//    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
//    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
//    areaGradient.angle = -90.0;
//    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
//    dataSourceLinePlot.areaFill      = areaGradientFill;
//    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);
//    
//    // Animate in the new plot, as an example
//    dataSourceLinePlot.opacity = 0.0;
//    [newGraph addPlot:dataSourceLinePlot];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0;
    [boundLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    //[dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
//    // Add some initial data
//    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
//    for ( NSUInteger i = 0; i < 60; i++ ) {
//        NSNumber *xVal = @(1.0 + i * 0.05);
//        NSNumber *yVal = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);
//        [contentArray addObject:@{ @"x": xVal,
//                                   @"y": yVal }
//         ];
//    }
//    self.dataForPlot = contentArray;
    
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}


-(void)configureXAxisForGraph:(CPTGraph*)graph{
    
    const NSTimeInterval oneSecond = 60;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTPlotRange *xAxisRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromString(@"0.0") length:CPTDecimalFromString(@"24.0")];

    x.majorIntervalLength = CPTDecimalFromDouble(6.0);
    //x.minorTicksPerInterval = 5;
//    x.majorTickLineStyle = lineStyle;
//    x.minorTickLineStyle = lineStyle;
//    x.axisLineStyle = lineStyle;
    x.minorTickLength = 3.0f;
    x.visibleRange = xAxisRange;
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.title = @"Hours";
    x.titleOffset = 47.0f;
    x.labelRotation = M_PI/4;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:0],[NSDecimalNumber numberWithInt:3], [NSDecimalNumber numberWithInt:6], [NSDecimalNumber numberWithInt:9], [NSDecimalNumber numberWithInt:12],
                                    [NSDecimalNumber numberWithInt:15], [NSDecimalNumber numberWithInt:18], [NSDecimalNumber numberWithInt:21], [NSDecimalNumber numberWithInt:24],nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"0 AM", @"3 AM", @"6 AM", @"9 AM", @"12PM", @"3 PM",@"6 PM",@"9 PM", @"12 AM", nil];
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = x.labelOffset + x.majorTickLength;
        newLabel.rotation = M_PI/4;
        [customLabels addObject:newLabel];
        //[newLabel release];
    }
    x.axisLabels =  [NSSet setWithArray:customLabels];
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
    return self.dataForPlot.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.dataForPlot[index][key];
    
    // Green plot gets shifted above the blue
    if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
        if ( fieldEnum == CPTScatterPlotFieldY ) {
            num = @([num doubleValue] + 1.0);
        }
    }
    return num;
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
//    [self dismissViewControllerAnimated:YES completion:^{
//       // to do
//    }];
}

@end
