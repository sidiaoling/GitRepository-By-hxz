//
//  UILabel+TRLabel.m
//  TRWeather
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "UILabel+TRLabel.h"

@implementation UILabel (TRLabel)

+(UILabel *)labelWithFrameByCategory:(CGRect)rect
{
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    //设置字体 www.iosfont.com
    UIFont *font = [UIFont fontWithName:@"HelveticalNeue-Light" size:28];
    label.font = font;
    
    return label;
}

@end
