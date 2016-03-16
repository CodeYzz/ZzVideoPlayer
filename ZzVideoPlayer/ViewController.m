//
//  ViewController.m
//  VedioPlayer
//
//  Created by lanou on 16/1/15.
//  Copyright © 2016年 yan. All rights reserved.
//

#import "ViewController.h"
#import "ZzMovieViewController.h"

#define URL @"http://mw5.dwstatic.com/2/4/1529/134981-99-1436844583.mp4"

@interface ViewController ()




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 300, 60, 60);
    [button setTitle:@"Play" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(PlayVideo) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)PlayVideo {
    
    ZzMovieViewController *ZzMovieVC = [[ZzMovieViewController alloc]init];
    ZzMovieVC.videoURL = URL;
    [self presentViewController:ZzMovieVC animated:YES completion:nil];
    
}





@end
