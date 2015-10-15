//
//  ZYMusicViewController.m
//  ZYMusicPlayer
//
//  Created by 王志盼 on 15/10/13.
//  Copyright © 2015年 王志盼. All rights reserved.
//

#import "ZYMusicViewController.h"
#import "ZYPlayingViewController.h"
#import "ZYMusicTool.h"
#import "ZYMusic.h"
#import "ZYImageTool.h"
#import "Colours.h"
@interface ZYMusicViewController ()
@property (nonatomic, strong) ZYPlayingViewController *playingVc;
@end

@implementation ZYMusicViewController

- (ZYPlayingViewController *)playingVc
{
    if (_playingVc == nil) {
        _playingVc = [[ZYPlayingViewController alloc] initWithNibName:@"ZYPlayingViewController" bundle:nil];
    }
    return _playingVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
}

- (void)setupNavigation
{
    self.navigationItem.title = @"音乐播放器";
}

#pragma mark ----TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ZYMusicTool musics].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifie = @"MusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifie];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifie];
    }
    ZYMusic *music = [ZYMusicTool musics][indexPath.row];
    cell.textLabel.text = music.name;
    cell.detailTextLabel.text = music.singer;
    cell.imageView.image = [ZYImageTool circleImageWithName:music.singerIcon borderWidth:2.0 borderColor:[UIColor pinkColor]] ;
    return cell;
}

#pragma mark ----TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [ZYMusicTool setPlayingMusic:[ZYMusicTool musics][indexPath.row]];
    
    [self.playingVc show];
}

@end
