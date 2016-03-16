//
//  ZzMovieViewController.m
//  ZzVideoPlayer
//
//  Created by lanou on 16/3/16.
//  Copyright © 2016年 yan. All rights reserved.
//

#import "ZzMovieViewController.h"
#import "Header.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "MyActivityIndicatorView.h"

@interface ZzMovieViewController ()
{
    NSTimer *timer;
    CGFloat number;
    PanDirection panDirection; // 定义一个实例变量，保存枚举值
    BOOL isVolume; // 判断是否正在滑动音量
    CGFloat sumTime; // 用来保存快进的总时长
}

@property (nonatomic,strong)UIView *container;
@property (nonatomic,strong)AVPlayer *player;//播放器
@property (nonatomic,strong)UIButton *playButton; //播放按钮
@property (nonatomic,strong)UIButton *midPlayButton;
@property (nonatomic,strong)UISlider *voiceSlider;
@property (nonatomic,strong)UIButton *voiceButton;
@property (nonatomic,strong)UIButton *backButton;//返回按钮
@property (nonatomic,strong)UILabel *timeLabel; //时间条
@property (nonatomic,strong)UIProgressView *progressView; //进度条
@property (nonatomic,strong)UISlider *progressSlider; //滑竿
@property (nonatomic,strong)MyActivityIndicatorView *activity;  //加载条
@property (nonatomic,strong)UILabel *showVoiceLabel;
@property (nonatomic,strong)UILabel *horizontalProgressLabel;   // 设置进度条
@property (nonatomic,strong)UILabel *volumeLabel;
@property (nonatomic,strong)AVPlayerLayer *playerLayer;

@end

@implementation ZzMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 设置界面
    [self  setupUI];
    
    if (kNetState != 0)
    {
        [self setupVideo];
    }
}

#pragma mark 设置播放页面
- (void)setupUI{
    //播放view
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight)];
    self.container.center = CGPointMake(kScreenWidth/2.0, kScreenHeight/2.0);
    [self.view addSubview:self.container];
    
    
    //播放按钮
    self.midPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.midPlayButton.frame = CGRectMakeInline(195, 360, 25, 25);
    self.midPlayButton.center = self.container.center;
    [self.midPlayButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
    [self.view addSubview: self.midPlayButton];
    [self.midPlayButton addTarget:self action:@selector(playAndPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMakeInline(0, 680, 25, 25);
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
    [self.view addSubview:self.playButton];
    [self.playButton addTarget:self action:@selector(playAndPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置时间label
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMakeInline(265, 710, 120, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.timeLabel];
    
    
    // 声音按钮
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton.frame = CGRectMakeInline(0, 0, 25, 25);
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [self.view addSubview:self.voiceButton];
    [self.voiceButton addTarget:self action:@selector(showVoice) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 音量条
    self.voiceSlider = [[UISlider alloc]initWithFrame:CGRectMakeInline(- 40, 630, 120, 30)];
    [self.voiceSlider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    self.voiceSlider.value = 0.5;
    self.voiceSlider.alpha = 0;
    [self.view addSubview:self.voiceSlider];
    CGAffineTransform voiceTransform = CGAffineTransformMakeRotation( - M_PI / 2  );
    [self.voiceSlider setTransform:voiceTransform];
    
    [self.voiceSlider addTarget:self action:@selector(ajustVolume) forControlEvents:UIControlEventValueChanged];
    
    
    
    // 返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMakeInline(5, 5, 40, 25);
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"back_@128.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 缓存条
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMakeInline(50, 710,320, 2)];
    self.progressView.trackTintColor = [UIColor darkGrayColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    
    // 水平滑动显示的进度label
    self.horizontalProgressLabel = [[UILabel alloc]initWithFrame:CGRectMakeInline(250, 500, 150, 30)];
    self.horizontalProgressLabel.font = [UIFont systemFontOfSize:14];
    self.horizontalProgressLabel.textAlignment = NSTextAlignmentCenter;
    self.horizontalProgressLabel.textColor = [UIColor whiteColor];
    self.horizontalProgressLabel.text = @"00:00 / --:--";
    // 一上来先隐藏
    self.horizontalProgressLabel.alpha = 0;
    
    
    
    //滑动条设置
    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMakeInline(50,0, 320, 20)];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [self.view addSubview:self.progressSlider];
    
    // 重新设置控件终点位置
    self.progressSlider.center = self.progressView.center;
    self.voiceButton.center = CGPointMake(self.view.frame.size.width / 15, self.progressSlider.center.y);
    self.playButton.center = CGPointMake(self.progressView.frame.origin.x + self.progressView.frame.size.width * 1.05, self.progressSlider.center.y);
    
    self.activity = [[MyActivityIndicatorView alloc]initWithFrame:CGRectMakeInline(140,200, 60, 60)];
    self.activity.center = CGPointMake(self.container.center.x, self.container.center.y);
    
    [self.view addSubview:self.activity];
    [self.activity startAnimating];
    
    //设置默认音量
    self.player.volume = 0.5;
    
    //先关闭交互
    self.playButton.userInteractionEnabled = NO;
    self.midPlayButton.userInteractionEnabled = NO;
    self.container.userInteractionEnabled = NO;
    
    //处理进度条和滑动条
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.progressSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
    
    //添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(show)];
    [self.container addGestureRecognizer:tap];
    
    // 添加平移手势，用来控制音量和快进快退
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self.container addGestureRecognizer:pan];
    
    
    
}


#pragma mark 设置视频播放
- (void)setupVideo{
    
    //创建播放器层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.container.layer.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //视频填充模式
    [self.container.layer addSublayer:self.playerLayer];
    [self.container addSubview:self.horizontalProgressLabel];
}

#pragma mark 懒加载，初始化播放器 return 播放器对象

- (AVPlayer*)player
{
    if (_player == nil)
    {
        AVPlayerItem *playerItem = [self playItemWithURL];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        if (kNetState != 0)
        {
            //观察进度
            [self addTimeObserver];
            // 观察播放状态
            [self addObserverToPlayerItem:playerItem];
            // 播放完成通知
            [self addNotification];
        }
    }
    return _player;
}
//   创建playerItem
- (AVPlayerItem *)playItemWithURL{
    NSString *urlStr = [[NSString alloc]init];
    
    // 将网址编码
    urlStr = [self.videoURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return [AVPlayerItem playerItemWithURL:url];
    
}

#pragma mark 监控播放器
// 设置当前时间进度
- (void)addTimeObserver
{
    __weak ZzMovieViewController *weakSelf = self;
    
    
    //设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //将CMTime转换成当前秒数
        CGFloat current = CMTimeGetSeconds(time);
        
        
        // 将CMTime转换成总时间秒数
        CGFloat total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        //刷新slider的进度
        [weakSelf.progressSlider setValue:(current/total) animated:YES];
        //刷新时间戳，设置显示时间label
        NSString *timeString = [weakSelf convertTime:current];
        NSString *totalTimeString = [weakSelf convertTime:total];
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,totalTimeString];
        
    }];
}

#pragma -mark 时间转换,设置
- (NSString *)convertTime:(CGFloat)second
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置显示时间的格式
    if (second/3600 >= 1)
    {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:date];
    return showtimeNew;
}

#pragma mark 给AVPlayerItem添加监控
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem
{
    //监控status属性，得到播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}

#pragma mark  移除观察者
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
#pragma mark  观察者模式 @param keyPath 观察的属性 @param object  观察的对象 @param change  属性的变化 @param context 附加信息


// 观察播放的状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = object;
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay)
        {
            [self.activity stopAnimating];
            
            
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause_@128"] forState:UIControlStateNormal];
            [self.midPlayButton setBackgroundImage:[UIImage imageNamed:@"pause_@128"] forState:UIControlStateNormal];
            
            [self.player play];
            
            self.container.userInteractionEnabled = YES;
            // 隐藏控件
            [self performSelector:@selector(timeStart) withObject:nil afterDelay:2.0];
            
            //开启交互
            [self function];
            
            //开启滑竿快进功能
            [self.progressSlider addTarget:self action:@selector(changeTime) forControlEvents:UIControlEventValueChanged];
            
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        
        // 视频已经加载好的缓存范围
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [[array firstObject] CMTimeRangeValue];//本次缓冲的时间范围
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        CGFloat rangeSeconds = CMTimeGetSeconds(timeRange.duration);
        CGFloat durationSeconds = CMTimeGetSeconds(playerItem.duration);
        // 设置已经下载的长度
        CGFloat percent = (startSeconds+rangeSeconds)/durationSeconds;
        
        self.progressView.progress = percent;
    }
}



#pragma mark 添加播放器通知

// 观察是否播放完成
- (void)addNotification
{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma mark - 横屏 竖屏的时候frame的设置
- (void)statusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        [self setRightHorizonFrame];
    }
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        [self setLeftHorizonFrame];
        
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        //  竖屏的时候
        [self setVerticalFrame];
    }
}



- (void)setRightHorizonFrame{
    NSLog(@"Right");
    
    self.container.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.playerLayer.frame = self.container.layer.bounds;
    
    self.activity.center = CGPointMake(self.container.center.x, self.container.center.y);
    self.backButton.frame = CGRectMakeInline(5, 5, 30, 40);
    self.midPlayButton.center = CGPointMake(self.container.center.x, self.container.center.y);
    self.timeLabel.frame = CGRectMakeInline(300, 700, 120, 30);
    
    self.voiceButton.center = CGPointMakeInline(20, 700);
    self.voiceSlider.center = CGPointMakeInline(15, 585);
    
    self.progressView.frame = CGRectMakeInline(35, 695, 350, 5);
    self.progressSlider.frame = CGRectMakeInline(0, 0, 350,20);
    self.horizontalProgressLabel.frame = CGRectMakeInline(250, 600, 150, 30);
    
    // 重新设置控件终点位置
    self.progressSlider.center = self.progressView.center;
    self.playButton.center = CGPointMake(self.progressView.frame.origin.x + self.progressView.frame.size.width * 1.03, self.progressSlider.center.y);
    
}


- (void)setLeftHorizonFrame{
    NSLog(@"Left");
    
    self.container.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.playerLayer.frame = self.container.layer.bounds;
    
    self.activity.center = CGPointMake(self.container.center.x, self.container.center.y);
    self.backButton.frame = CGRectMakeInline(5, 5, 30, 40);
    self.midPlayButton.center = CGPointMake(self.container.center.x, self.container.center.y);
    self.timeLabel.frame = CGRectMakeInline(300, 700, 120, 30);
    
    self.voiceButton.center = CGPointMakeInline(20, 700);
    self.voiceSlider.center = CGPointMakeInline(15, 585);
    
    self.progressView.frame = CGRectMakeInline(35, 695, 350, 5);
    self.progressSlider.frame = CGRectMakeInline(0, 0, 350,20);
    self.horizontalProgressLabel.frame = CGRectMakeInline(250, 600, 150, 30);
    
    // 重新设置控件终点位置
    self.progressSlider.center = self.progressView.center;
    self.playButton.center = CGPointMake(self.progressView.frame.origin.x + self.progressView.frame.size.width * 1.03, self.progressSlider.center.y);
    
}

- (void)setVerticalFrame{
    
    NSLog(@"Vertical");
    self.container.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.playerLayer.frame = self.container.layer.bounds;
    self.container.center = CGPointMake(kScreenWidth/2.0, kScreenHeight/2.0);
    
    self.midPlayButton.center = CGPointMake(self.container.center.x, self.container.center.y);
    self.activity.center = CGPointMake(self.container.center.x, self.container.center.y);
    
    
    self.backButton.frame = CGRectMakeInline(5, 5, 40, 25);
    
    self.timeLabel.frame = CGRectMakeInline(265, 710, 120, 30);
    self.voiceSlider.center = CGPointMakeInline(20, 645);
    
    // 进度条
    self.progressView.frame = CGRectMakeInline(50, 710,320, 2);
    self.progressSlider.frame = CGRectMakeInline(50,0, 320, 20);
    self.horizontalProgressLabel.frame = CGRectMakeInline(250, 500, 150, 30);
    
    // 重新设置控件终点位置
    self.progressSlider.center = self.progressView.center;
    self.voiceButton.center = CGPointMake(self.view.frame.size.width / 15, self.progressSlider.center.y);
    self.playButton.center = CGPointMake(self.progressView.frame.origin.x + self.progressView.frame.size.width * 1.05, self.progressSlider.center.y);
}



#pragma mark 移除播放器通知
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playFinished:(NSNotification *)notification
{
    [self endAction];
}

- (void)endAction{
    //暂停
    [self.player pause];
    
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
    [self.midPlayButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
    
    [timer setFireDate:[NSDate distantPast]];
}

#pragma -mark 改变进度
- (void)changeTime
{
    
    
    //定时器关闭
    [timer setFireDate:[NSDate distantFuture]];
    //显示功能模块
    [self function];
    //
    if (self.player.rate == 0) {
        CGFloat percent = self.progressSlider.value/self.progressSlider.maximumValue;
        CGFloat totalSecond = CMTimeGetSeconds(self.player.currentItem.duration);
        NSTimeInterval currentTime = totalSecond * percent;
        
        [self.player.currentItem seekToTime:CMTimeMake(currentTime, 1)];
        
    }else{
        [self.player pause];
        CGFloat percent = self.progressSlider.value/self.progressSlider.maximumValue;
        CGFloat totalSecond = CMTimeGetSeconds(self.player.currentItem.duration);
        NSTimeInterval currentTime = totalSecond * percent;
        [self.player.currentItem seekToTime:CMTimeMake(currentTime, 1)];
        
        [self.player play];
    }
    //开启定时器
    [timer setFireDate:[NSDate distantPast]];
}

#pragma mark - 定时器方法
- (void)timeStart{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(dismiss) userInfo:nil repeats:YES];
}

// 让控件逐渐隐藏
- (void)dismiss
{
    
    if (self.playButton.alpha <= 0)
    {
        //消失后关闭交互
        self.playButton.userInteractionEnabled = NO;
        self.midPlayButton.userInteractionEnabled = NO;
        self.voiceButton.userInteractionEnabled = NO;
        self.backButton.userInteractionEnabled = NO;
        self.progressSlider.userInteractionEnabled = NO;
        self.voiceSlider.userInteractionEnabled = NO;
    }
    
    else
    {
        self.playButton.alpha -= 0.02;
        self.midPlayButton.alpha -= 0.02;
        self.voiceButton.alpha -= 0.02;
        self.progressView.alpha -= 0.02;
        self.backButton.alpha -= 0.02;
        self.timeLabel.alpha -= 0.02;
        self.progressSlider.alpha -= 0.02;
        self.voiceSlider.alpha -= 0.02;
    }
}

#pragma -mark 保持图标及功能
- (void)function
{
    self.playButton.alpha = 1;
    self.midPlayButton.alpha = 1;
    self.progressSlider.alpha = 1;
    self.progressView.alpha = 1;
    self.backButton.alpha = 1;
    self.timeLabel.alpha = 1;
    self.voiceButton.alpha = 1;
    
    //开启交互
    self.playButton.userInteractionEnabled = YES;
    self.midPlayButton.userInteractionEnabled = YES;
    self.progressSlider.userInteractionEnabled = YES;
    self.backButton.userInteractionEnabled = YES;
    self.voiceButton.userInteractionEnabled = YES;
}

#pragma -mark tap触发的方法
- (void)show
{
    if (self.playButton.alpha >=0.6)
    {
        //暂停, 若控件可见,执行播放或暂停
        [self playAndPauseAction:self.playButton];
    }
    [self function];
}

- (void)playAndPauseAction:(UIButton *)button
{
    // rate = 1，表明正在播放
    if (self.player.rate == 1)
    {
        [self.player pause];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
        [self.midPlayButton setBackgroundImage:[UIImage imageNamed:@"play_@128"] forState:UIControlStateNormal];
    }
    else
    {
        
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause_@128"] forState:UIControlStateNormal];
        [self.midPlayButton setBackgroundImage:[UIImage imageNamed:@"pause_@128"] forState:UIControlStateNormal];
        
        CGFloat currentTime = CMTimeGetSeconds(self.player.currentTime);
        
        CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
        if (currentTime == totalTime) {
            [self.player seekToTime:CMTimeMake(0, 1)];
        }
        [self.player play];
    }
}

#pragma mark 平移的方向，改变进度和音量大小
- (void)panDirection:(UIPanGestureRecognizer *)pan{
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self.container];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                
                panDirection = PanDirectionHorizontalMoved;
                // 取消隐藏
                self.horizontalProgressLabel.alpha = 1;
                NSLog(@"%d",self.horizontalProgressLabel.hidden);
                // 给sumTime初值
                sumTime = CMTimeGetSeconds(self.player.currentTime);
            }
            else if (x < y){ // 垂直移动
                panDirection = PanDirectionVerticalMoved;
                // 显示音量控件
                //                self.volume.hidden = NO;
                // 开始滑动的时候，状态改为正在控制音量
                isVolume = YES;
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            
            // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{
                    // 隐藏视图
                    self.horizontalProgressLabel.alpha = 0;
                    // 在滑动结束后，视屏要跳转
                    [self.player seekToTime:CMTimeMake(sumTime, 1)];
                    
                    // 把sumTime滞空，不然会越加越多
                    sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，隐藏音量控件
                    //                    self.volume.hidden = YES;
                    // 且，把状态改为不再控制音量
                    isVolume = NO;
                    break;
                }
                default:
                    break;
                    
            }
            break;
            
        }
            
        default:
            break;
    }
    
    
}

#pragma mark - pan水平移动的方法
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
    }
    else if (value > 0){
        style = @">>";
    }
    
    // 每次滑动需要叠加时间
    sumTime += value / 200;
    
    // 需要限定sumTime的范围
    if (sumTime > CMTimeGetSeconds(self.player.currentItem.duration)) {
        sumTime = CMTimeGetSeconds(self.player.currentItem.duration);
    }else if (sumTime < 0){
        sumTime = 0;
    }
    
    // 当前快进的时间
    NSString *nowTime = [self durationStringWithTime:(int)sumTime];
    // 总时间
    NSString *durationTime = [self durationStringWithTime:(int)CMTimeGetSeconds(self.player.currentItem.duration)];
    // 给label赋值
    self.horizontalProgressLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
    
}

#pragma mark - pan垂直移动的方法
- (void)verticalMoved:(CGFloat)value
{
    //    // 更改音量控件value
    //    self.volume.value -= value / 10000; // 越小幅度越小
    //    // 更改系统的音量
    //    self.volumeSlider.value = self.volume.value;
    
}

#pragma mark - 根据时长求出字符串
- (NSString *)durationStringWithTime:(int)time
{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}

#pragma mark 改变音量
- (void)showVoice{
    [timer setFireDate:[NSDate distantFuture]];
    [self  function];
    
    if (self.voiceSlider.userInteractionEnabled == NO) {
        self.voiceSlider.userInteractionEnabled = YES;
        self.voiceSlider.alpha = 1;
    }else{
        self.voiceSlider.userInteractionEnabled = NO;
        self.voiceSlider.alpha = 0;
    }
    [timer setFireDate:[NSDate distantPast]];
}

- (void)ajustVolume{
    
    [timer setFireDate:[NSDate distantFuture]];
    [self  function];
    self.voiceSlider.alpha = 1;
    self.player.volume = self.voiceSlider.value;
    [timer setFireDate:[NSDate distantPast]];
    
}

- (void)back{
    
    //    //返回暂停并且置空
    //    [self.player pause];
    //    //移除观察者
    //    [self removeObserverFromPlayerItem:self.player.currentItem];
    //    [self removeNotification];
    //    [self.player replaceCurrentItemWithPlayerItem:nil];
    //
    //
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"返回");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
