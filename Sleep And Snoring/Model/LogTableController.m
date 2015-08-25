//
//  LogTableController.m
//  SnoreStreamer
//
//  Created by Guy Brown on 21/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "LogTableController.h"
#import "AudioManager.h"
#import "AudioModel.h"
@interface LogTableController ()
@end

@implementation LogTableController

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redisplay:)
                                                 name:@"NOTIFY_REFRESH_TABLE"
                                               object:nil];
    
    self.dataSource = [self getAllFiles];
}

-(void)awakeFromNib
{
    // nasty problem with layout - if the table view is not inside a navigation
    // controller then it will overlap the menu bar. This will fix it.
    [self.tableView setContentInset:UIEdgeInsetsMake(20, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)];
}

-(void)redisplay:(NSNotification*)notif
{
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogTableCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"LogTableCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // show the size of each record
    NSURL *fileURL = [NSURL URLWithString:self.dataSource[indexPath.row]];
    NSDictionary *fileDictionary = [[NSFileManager defaultManager]attributesOfItemAtPath:fileURL.absoluteString error:nil];
    unsigned long long fileSize = [fileDictionary fileSize];

    // display the name of file and the size of file
    cell.textLabel.text = [self.dataSource[indexPath.row] lastPathComponent];
    cell.detailTextLabel.text = [self stringFromFileSize:fileSize];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove the file
        [[NSFileManager defaultManager] removeItemAtPath: self.dataSource[indexPath.row] error: nil];
        // refresh data source
        self.dataSource = [self getAllFiles];
        [tableView reloadData];
    }
}

- (IBAction)refresh:(UIRefreshControl *)sender {

    self.dataSource = [self getAllFiles];
    [self.tableView reloadData];
    [sender endRefreshing];
}

/*-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
 */

-(NSArray *)getAllFiles {
    // discovery all the files in Documents/snore
    NSMutableArray *allFiles = [[NSMutableArray alloc] init];
    NSString *folderPath = [AudioModel audioFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString *fileName in files) {
            [allFiles addObject:[folderPath stringByAppendingPathComponent:fileName]];
        }
        //NSLog(@"files array %@", allFiles);
    }

    return allFiles;
}


- (NSString *)stringFromFileSize:(unsigned long long)fileSize {
    long double size = 0.0;
    if (fileSize / 1024 < 1) {
        return [NSString stringWithFormat:@"%llu B", fileSize];
    } else {
        size = fileSize / 1024.0;
    }
    if (size / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2Lf KB", size];
    } else {
        size = size / 1024.0;
    }
    
    return [NSString stringWithFormat:@"%.2Lf MB", size];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
@end
