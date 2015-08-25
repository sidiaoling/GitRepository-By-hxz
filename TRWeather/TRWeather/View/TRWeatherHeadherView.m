//
//  TRWeatherHeadherView.m
//  TRWeather
//
//  Created by apple on 15/8/10.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TRWeatherHeadherView.h"
#import "TRLabelTool.h"//创建lable的创建tool
#import "UILabel+TRLabel.h"//分类

//定义几个常量
static CGFloat inset = 20;//左右的边距
static CGFloat tempertureHeight = 110;
static CGFloat cityHeight = 30;
static CGFloat hiloHeight = 40;
static CGFloat statusHeight = 20;


@implementation TRWeatherHeadherView

//重写initwithframe方法
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //cityLabel:
        CGRect cityFrame = CGRectMake(0, statusHeight, frame.size.width, cityHeight);
        //self.cityLabel = [[UILabel alloc]initWithFrame:cityFrame];
        //self.cityLabel = [TRLabelTool labelWithFrame:cityFrame];//使用一个工具类来创建
        //使用分类来创建label
        self.cityLabel = [UILabel labelWithFrameByCategory:cityFrame];
        //self.cityLabel.text = @"Loading...";
        [self addSubview:self.cityLabel];
        //最底部的最高最低温度label
        CGRect hiloFrame = CGRectMake(inset, frame.size.height-hiloHeight, frame.size.width-2*inset, hiloHeight);
        self.hiloLabel = [UILabel labelWithFrameByCategory:hiloFrame];
        self.hiloLabel.text = @"";
        self.hiloLabel.textAlignment = NSTextAlignmentLeft;
        //self.hiloLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.hiloLabel];
        //温度label
        CGRect temperFrame = CGRectMake(inset, frame.size.height-hiloHeight-tempertureHeight, frame.size.width-2*inset, tempertureHeight);
        self.temperatureLabel = [UILabel labelWithFrameByCategory:temperFrame];
        self.temperatureLabel.text = @"0˚";
        self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:120];
        self.temperatureLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.temperatureLabel];
        
        //iconView
        CGRect iconFrame = CGRectMake(inset, temperFrame.origin.y-cityHeight, cityHeight, cityHeight);
        self.iconView = [[UIImageView alloc]initWithFrame:iconFrame];
        self.iconView.image = [UIImage imageNamed:@"weather-clear.png"];
        [self addSubview:self.iconView];
        //conditionsLabel
        CGRect conditionsFrame = CGRectMake(iconFrame.origin.x+cityHeight, iconFrame.origin.y, frame.size.width-2*inset-cityHeight, cityHeight);
        self.conditionsLabel = [UILabel labelWithFrameByCategory:conditionsFrame];
        self.conditionsLabel.text = @"Clear";
        //self.conditionsLabel.backgroundColor = [UIColor blueColor];
        self.conditionsLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.conditionsLabel];
    }
    return self;
}

@end
