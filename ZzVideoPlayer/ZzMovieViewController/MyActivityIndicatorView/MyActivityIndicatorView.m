//
//  MyActivityIndicatorView.m
//  VedioPlayer
//
//  Created by lanou on 16/1/16.
//  Copyright © 2016年 yan. All rights reserved.
//

#import "MyActivityIndicatorView.h"

@implementation MyActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    // 添加label
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 40, self.frame.size.width, 30)];
    label.text = @"加载中...";
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    return self;
}

@end
