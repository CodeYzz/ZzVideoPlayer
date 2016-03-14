//
//  Header.h
//  LOL
//
//  Created by lanou on 15/9/23.
//  Copyright (c) 2015年 hai. All rights reserved.
//






//适配
// 获取屏幕尺寸
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

// 适配比例
#define KHeightScale ([UIScreen mainScreen].bounds.size.height/667.)
#define KWidthScale ([UIScreen mainScreen].bounds.size.width/375.)

//色调
#define KBGColor   ([UIColor colorWithRed:255/255.0 green:250/250.0 blue:240/250.0 alpha:1.000])
#define KGrayColor ([UIColor colorWithWhite:0.375 alpha:1.000])
#define KSelectedColor ([UIColor colorWithRed:207/255.0 green:207/250.0 blue:207/250.0 alpha:1.000])
// bar高度
#define kTabbarHeight (40 / 667. * kScreenHeight)

// 当前网络状态
//结果说明：0-无连接   1-wifi    2-移动网络
#define kNetState [[Reachability reachabilityWithHostName:@"www.apple.com"] currentReachabilityStatus]

