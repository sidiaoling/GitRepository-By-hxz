//
//  TRWeatherModel.m
//  TRWeather
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TRWeatherModel.h"

@implementation TRWeatherModel

+(id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic
{
    return [[self alloc] initWithHourlyJSON:hourlyDic];
}
-(id)initWithHourlyJSON:(NSDictionary *)hourlyDic
{
    self = [super init];
    if (self) {
        //tempC
        self.tempforNow = [hourlyDic[@"tempC"] floatValue];
        //time
        self.time = [hourlyDic[@"time"] floatValue]/100;
        //iconURL
        NSString *iconStr = hourlyDic[@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    return self;
}

+(id)weatherWithdailyJSON:(NSDictionary *)dailyDic
{
    return [[self alloc] initWithDaily:dailyDic];
}
-(id)initWithDaily:(NSDictionary *)dailyDic
{
    self = [super init];
    if (self) {
        self.date = dailyDic[@"date"];
        self.maxTemp = [dailyDic[@"maxtempC"] floatValue];
        self.minTemp = [dailyDic[@"mintempC"] floatValue];
        self.iconURL = [NSURL URLWithString: dailyDic[@"hourly"][0][@"weatherIconUrl"][0][@"value"]];
        
    }
    return self;
}

+(id)weatherWithcurrentJSON:(NSDictionary *)currentDic
{
    return [[self alloc] initWithCurrent:currentDic];
}

-(id)initWithCurrent:(NSDictionary *)currentDic
{
    self = [super init];
    if (self) {
        self.cityName = currentDic[@"data"][@"request"][0][@"query"];
        self.iconURL = [NSURL URLWithString: currentDic[@"data"][@"current_condition"][0][@"weatherIconUrl"][0][@"value"]];
        self.weatherDesc = currentDic[@"data"][@"current_condition"][0][@"weatherDesc"][0][@"value"];
        self.tempforNow =[currentDic[@"data"][@"current_condition"][0][@"temp_C"] floatValue];
        self.maxTemp = [currentDic[@"data"][@"weather"][0][@"maxtempC"] floatValue];
        self.minTemp = [currentDic[@"data"][@"weather"][0][@"mintempC"] floatValue];
    }
    return self;
}

@end
