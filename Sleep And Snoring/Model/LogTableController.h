//
//  LogTableController.h
//  SnoreStreamer
//
//  Created by Guy Brown on 21/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LogTableController : UITableViewController<AVAudioPlayerDelegate>
@property (strong, nonatomic) NSArray *dataSource;
@end
