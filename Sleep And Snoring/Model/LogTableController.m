//
//  LogTableController.m
//  SnoreStreamer
//
//  Created by Guy Brown on 21/04/2015.
//  Copyright (c) 2015 Guy Brown. All rights reserved.
//

#import "LogTableController.h"
#import "AudioManager.h"
@interface LogTableController ()
@property (strong, nonatomic)AVAudioPlayer *player;
@property (assign)BOOL isPlaying;
@end

@implementation LogTableController

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redisplay:)
                                                 name:@"NOTIFY_REFRESH_TABLE"
                                               object:nil];
    
    self.audioFiles = [self getAllFiles];
    self.isPlaying = NO;
    
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
    cell.textLabel.text = [self.audioFiles[indexPath.row] lastPathComponent];
    cell.detailTextLabel.text = @"unknown";
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // the data model is a singleton
    return self.audioFiles.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.isPlaying) {
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        NSError *error = nil;
        NSLog(@"THE AUDIO PATH : %@", self.audioFiles[indexPath.row]);
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.audioFiles[indexPath.row]] error:&error];
        [self.player setDelegate:self];
        if (!error) {
            [self.player prepareToPlay];
            self.isPlaying = [self.player play];
        } else {
            NSLog(@"Error : %@", error);
        }
        

        NSLog(@"Is playing : %i", self.isPlaying);
    } else {
        [self.player stop];
        self.isPlaying = NO;
        NSLog(@"Cannot play");
    }
}


- (IBAction)refresh:(UIRefreshControl *)sender {

    self.audioFiles = [self getAllFiles];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"/snore"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString *fileName in files) {
            [allFiles addObject:[folderPath stringByAppendingPathComponent:fileName]];
        }
        NSLog(@"files array %@", allFiles);
    }

    return allFiles;
}

#pragma mark accessor



#pragma mark delegate methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.isPlaying = NO;
    NSLog(@"Finish playing");
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"error happens during playing");
}

@end
