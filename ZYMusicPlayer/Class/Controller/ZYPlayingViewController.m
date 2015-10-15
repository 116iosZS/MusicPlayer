//
//  ZYPlayingViewController.m
//  ZYMusicPlayer
//
//  Created by 王志盼 on 15/10/13.
//  Copyright © 2015年 王志盼. All rights reserved.
//

#import "ZYPlayingViewController.h"
#import "UIView+Extension.h"
#import "ZYMusic.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYMusicTool.h"
#import "ZYAudioManager.h"
@interface ZYPlayingViewController ()  <AVAudioPlayerDelegate>

@property (nonatomic, strong) ZYMusic *playingMusic;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
/**
 *  判断歌曲播放过程中是否被电话等打断播放
 */
@property (nonatomic, assign) BOOL isInterruption;
/**
 *  歌手图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
/**
 *  歌曲名字
 */
@property (strong, nonatomic) IBOutlet UILabel *songLabel;
/**
 *  歌手名字
 */
@property (strong, nonatomic) IBOutlet UILabel *singerLabel;
/**
 *  暂停\播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
/**
 *  整首歌是多长时间
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/**
 *  歌曲进度颜色背景
 */
@property (weak, nonatomic) IBOutlet UIView *progressView;
/**
 *  歌曲滑块
 */
@property (weak, nonatomic) IBOutlet UIButton *slider;
/**
 *  滑块上面显示当前时间的label
 */
@property (weak, nonatomic) IBOutlet UIButton *showProgressLabel;


/**
 *  显示图片还是歌词
 *
 */
- (IBAction)lyricOrPhoto:(id)sender;
/**
 *  暂停或者播放
 *
 */
- (IBAction)playOrPause:(id)sender;
/**
 *  退下窗口
 *
 */
- (IBAction)exit:(UIButton *)sender;
/**
 *  拖拽滑块时，调用的方法
 *
 */
- (IBAction)panSlider:(UIPanGestureRecognizer *)sender;
/**
 *  点击背景时，滑块调整位置时调用的方法
 *
 */
- (IBAction)tapProgressView:(UITapGestureRecognizer *)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;

@end

@implementation ZYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    [self.slider setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.slider.font = [UIFont systemFontOfSize:12];
}

- (void)show
{
//    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    self.view.bounds = windows.bounds;
    [windows addSubview:self.view];
    self.view.y = self.view.height;
    self.view.hidden = NO;
    if (self.playingMusic != [ZYMusicTool playingMusic]) {
        [self resetPlayingMusic];
    }
    
    windows.userInteractionEnabled = NO;         //以免在动画过程中用户多次点击，或者造成其他事件的发生
    [UIView animateWithDuration:1 animations:^{
        self.view.y = 0;
    }completion:^(BOOL finished) {
        windows.userInteractionEnabled = YES;
        [self startPlayingMusic];
    }];
}

#pragma mark ----音乐控制
//重置播放的歌曲
- (void)resetPlayingMusic
{
    // 重置界面数据
    self.iconView.image = [UIImage imageNamed:@"play_cover_pic_bg"];
    self.singerLabel.text = nil;
    self.songLabel.text = nil;
    self.timeLabel.text = [self stringWithTime:0];
    self.slider.x = 0;
    self.progressView.width = self.slider.center.x;
    [self.slider setTitle:[self stringWithTime:0] forState:UIControlStateNormal];
    
    //停止播放音乐
    [[ZYAudioManager defaultManager] stopMusic:self.playingMusic.filename];
    self.player = nil;
    
    [self removeCurrentTimer];
}

//开始播放音乐
- (void)startPlayingMusic
{
    if (self.playingMusic == [ZYMusicTool playingMusic])  {
        [self addCurrentTimer];
        return;
    }
    
    // 设置所需要的数据
    self.playingMusic = [ZYMusicTool playingMusic];
    self.iconView.image = [UIImage imageNamed:self.playingMusic.icon];
    self.songLabel.text = self.playingMusic.name;
    self.singerLabel.text = self.playingMusic.singer;
    
    //开发播放音乐
    self.player = [[ZYAudioManager defaultManager] playingMusic:self.playingMusic.filename];
    self.player.delegate = self;
    
    self.timeLabel.text = [self stringWithTime:self.player.duration];
    
    [self addCurrentTimer];
}

#pragma mark ----定时器处理

- (void)addCurrentTimer
{
    if (![self.player isPlaying]) return;
    
    //在新增定时器之前，先移除之前的定时器
    [self removeCurrentTimer];
    
    [self updateCurrentTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeCurrentTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateCurrentTimer
{
    double temp = self.player.currentTime / self.player.duration;
    self.slider.x = temp * (self.view.width - self.slider.width);
    [self.slider setTitle:[self stringWithTime:self.player.currentTime] forState:UIControlStateNormal];
    self.progressView.width = self.slider.center.x;
}

#pragma mark ----私有方法
- (NSString *)stringWithTime:(NSTimeInterval)time
{
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minute, second];
}


#pragma mark ----控件方法
- (IBAction)lyricOrPhoto:(UIButton *)sender {
    sender.selected = !sender.selected;
}



- (IBAction)exit:(id)sender {
    
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    windows.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:1 animations:^{
        self.view.y = self.view.height;
    }completion:^(BOOL finished) {
        self.view.hidden = YES;            //view看不到了，将之隐藏掉，可以减少性能的消耗
        [self removeCurrentTimer];
        windows.userInteractionEnabled = YES;
    }];
}

- (IBAction)panSlider:(UIPanGestureRecognizer *)sender {
    //得到挪动距离
    CGPoint point = [sender translationInView:sender.view];
    //将translation清空，免得重复叠加
    [sender setTranslation:CGPointZero inView:sender.view];

    CGFloat maxX = self.view.width - sender.view.width;
    sender.view.x += point.x;
    
    if (sender.view.x < 0) {
        sender.view.x = 0;
    }
    else if (sender.view.x > maxX){
        sender.view.x = maxX;
    }
    CGFloat time = (sender.view.x / (self.view.width - sender.view.width)) * self.player.duration;
    [self.showProgressLabel setTitle:[self stringWithTime:time] forState:UIControlStateNormal];
    [self.slider setTitle:[self stringWithTime:time] forState:UIControlStateNormal];
    self.progressView.width = sender.view.center.x;
    self.showProgressLabel.x = self.slider.x;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self removeCurrentTimer];
        self.showProgressLabel.hidden = NO;
        self.showProgressLabel.y = self.showProgressLabel.superview.height - 15 - self.showProgressLabel.height;
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        self.player.currentTime = time ;
        [self addCurrentTimer];
        self.showProgressLabel.hidden = YES;
    }
}

- (IBAction)tapProgressView:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    
    self.player.currentTime = (point.x / sender.view.width) * self.player.duration;
    
    [self updateCurrentTimer];
}

- (IBAction)playOrPause:(id)sender {
    if (self.playOrPauseButton.isSelected) {
        self.playOrPauseButton.selected = NO;
        [[ZYAudioManager defaultManager] playingMusic:self.playingMusic.filename];
        [self addCurrentTimer];
    }
    else{
        self.playOrPauseButton.selected = YES;
        [[ZYAudioManager defaultManager] pauseMusic:self.playingMusic.filename];
        [self removeCurrentTimer];
    }
}
- (IBAction)previous:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    [[ZYAudioManager defaultManager] stopMusic:self.playingMusic.filename];
    [ZYMusicTool setPlayingMusic:[ZYMusicTool previousMusic]];
    [self removeCurrentTimer];
    [self startPlayingMusic];
    window.userInteractionEnabled = YES;
}

- (IBAction)next:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    [[ZYAudioManager defaultManager] stopMusic:self.playingMusic.filename];
    [ZYMusicTool setPlayingMusic:[ZYMusicTool nextMusic]];
    [self removeCurrentTimer];
    [self startPlayingMusic];
    window.userInteractionEnabled = YES;
}

#pragma mark ----AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next:nil];
}
/**
 *  当电话给过来时，进行相应的操作
 *
 */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if ([self.player isPlaying]) {
        [self playOrPause:nil];
        self.isInterruption = YES;
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    if (self.isInterruption) {
        self.isInterruption = NO;
        [self playOrPause:nil];
    }
}
@end
