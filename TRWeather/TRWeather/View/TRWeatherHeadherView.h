//
//  TRWeatherHeadherView.h
//  TRWeather
//
//  Created by apple on 15/8/10.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRWeatherHeadherView : UIView

//城市
@property(nonatomic,strong)UILabel *cityLabel;

//天气图标
@property(nonatomic,strong)UIImageView *iconView;

//天气描述
@property(nonatomic,strong)UILabel *conditionsLabel;

//当前天气温度
@property(nonatomic,strong)UILabel *temperatureLabel;

//当天的最低最高温度
@property(nonatomic,strong)UILabel *hiloLabel;

@end
