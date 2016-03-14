//
//  ViewController.h
//  VedioPlayer
//
//  Created by lanou on 16/1/15.
//  Copyright © 2016年 yan. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_INLINE CGRect CGRectMakeInline(CGFloat x, CGFloat y,CGFloat width,CGFloat height){
    CGRect rect;
    
    // 1、算出缩放比例
    //以 6S Plus 为基准
    
    CGFloat autoSizeX = [UIScreen mainScreen].bounds.size.width / 414;
    CGFloat autoSizeY = [UIScreen mainScreen].bounds.size.height / 736;
    
    // 2 计算适配之后的X轴坐标 Y 轴坐标 以及 宽高
    rect.origin.x = x * autoSizeX;
    rect.origin.y = y * autoSizeY;
    rect.size.width = width * autoSizeX;
    rect.size.height = height * autoSizeY;
    
    return rect;
}

CG_INLINE CGPoint CGPointMakeInline(CGFloat x,CGFloat y){
    CGPoint rect;
    
    CGFloat  autoSizeX = [UIScreen mainScreen].bounds.size.width / 414;
    CGFloat  autoSizeY = [UIScreen mainScreen].bounds.size.height / 736;
    
    
    rect.x = x * autoSizeX;
    rect.y = y * autoSizeY;
    return rect;
}

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};

@interface ViewController : UIViewController

@property (nonatomic,strong)NSString *videoURL;

@end

