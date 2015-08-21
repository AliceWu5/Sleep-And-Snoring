//
//  LogTableController.m
//  SnoreStreamer
//
//  Created by Guy Brown on 21/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "LogTableController.h"
#import "Model.h"

@implementation LogTableController

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redisplay:)
                                                 name:@"NOTIFY_REFRESH_TABLE"
                                               object:nil];
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
    // the data model is a singleton
    //UploadManager *item = [Model sharedInstance].items[indexPath.row];
    //cell.textLabel.text = [item tableCellTitle];
    //cell.detailTextLabel.text = [item tableCellSubtitle];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // the data model is a singleton
    return [[Model sharedInstance].items count];
}

/*-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
 */

@end
