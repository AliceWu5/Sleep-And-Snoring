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

    NSURL *fileURL = [NSURL URLWithString:self.audioFiles[indexPath.row]];

    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    NSTimeInterval audioDurationSeconds = CMTimeGetSeconds(audioDuration);

    cell.textLabel.text = [self.audioFiles[indexPath.row] lastPathComponent];
    cell.detailTextLabel.text = [self stringFromTimeInterval:audioDurationSeconds];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // the data model is a singleton
    return self.audioFiles.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.isPlaying) {

        NSError *error = nil;

        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.audioFiles[indexPath.row]] error:&error];
        [self.player setDelegate:self];
        if (!error) {
            [self.player prepareToPlay];
            self.isPlaying = [self.player play];
        } else {
            NSLog(@"Error : %@", error);
        }
        
    } else {
        [self.player stop];
        self.isPlaying = NO;
        NSLog(@"Stop playing");
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove the file
        [[NSFileManager defaultManager] removeItemAtPath: self.audioFiles[indexPath.row] error: nil];
        // refresh data source
        self.audioFiles = [self getAllFiles];
        [tableView reloadData];
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


- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
@end