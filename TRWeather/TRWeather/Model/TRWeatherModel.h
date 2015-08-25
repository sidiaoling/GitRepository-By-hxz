//
//  TRWeatherModel.h
//  TRWeather
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRWeatherModel : NSObject

//日期
@property(nonatomic,strong)NSString *date;
//最高温度
@property(nonatomic,assign)float maxTemp;
//最低温度
@property(nonatomic,assign)float minTemp;
//每小时预报的时间time
@property(nonatomic,assign)float time;
//图片的图标URL
@property(nonatomic,strong)NSURL *iconURL;
//当下预报天气的温度
@property(nonatomic,assign)float tempforNow;
//天气描述
@property(nonatomic,strong)NSString *weatherDesc;
//城市名字
@property(nonatomic,strong)NSString *cityName;

//解析每个小时的天气情况
+(id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic;

//解析每天的天气情况(4个属性)
+(id)weatherWithdailyJSON:(NSDictionary *)dailyDic;

//解析头部视图的内容
+(id)weatherWithcurrentJSON:(NSDictionary *)currentDic;

@end
