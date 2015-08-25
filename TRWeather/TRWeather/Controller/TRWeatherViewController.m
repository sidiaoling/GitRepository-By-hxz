//
//  TRWeatherViewController.m
//  TRWeather
//
//  Created by apple on 15/8/10.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TRWeatherViewController.h"
#import "TRWeatherHeadherView.h"
#import "TRWeatherModel.h"

#import "UIImageView+WebCache.h"

@interface TRWeatherViewController ()<UITableViewDataSource,UITableViewDelegate>

//table view
@property(nonatomic,strong)UITableView *tabkeView;
//背景视图
@property(nonatomic,strong)UIImageView *backgroundImageView;

//声明一个数组属性，用来存放每天的天气情况，这里是多个天
@property(nonatomic,strong)NSArray *dailyArray;
//存放多个小时的天气情况
@property(nonatomic,strong)NSArray *hourlyArray;

@property(nonatomic,strong)TRWeatherHeadherView *headerView;

//声明一个非主队列,为了解决图片缓存的问题
@property(nonatomic,strong)NSOperationQueue *queue;
//创建一个字典，用来存下载下来的天气图片
@property(nonatomic,strong)NSMutableDictionary *imagesDic;
@property(nonatomic,strong)NSString *cachesPath;
@end

@implementation TRWeatherViewController

-(NSString *)cachesPath
{
    if (!_cachesPath) {
        _cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    }
    return _cachesPath;
}

-(NSMutableDictionary *)imagesDic//懒加载初始化缓存已经下载好的图片
{
    if (!_imagesDic) {
        _imagesDic = [NSMutableDictionary dictionary];
    }
    return _imagesDic;
}

//初始化
-(NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}

#pragma mark -- didReceiveMemoryWarning
-(void)didReceiveMemoryWarning//为了防止内存警告，在最后的内存警告方法中取消队列中所有的下载任务，防止闪退
{//正在下载的操作取消
    [self.queue cancelAllOperations];
    
    //清楚字典(内存)中的数据
    [self.imagesDic removeAllObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[self.tabkeView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    //初始化table view
    [self setUpTableView];
    
    //创建头部视图
    [self setUpHeaderView];
    
    //发送请求获取JSON数据
    [self sendRequestGetJSON];
    NSLog(@"%@",self.cachesPath);
}

-(void)sendRequestGetJSON
{
    //request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=huizhou&num_of_days=2&format=json&tp=6&key=3f6763d34215b10cabe89a6d85177"]];
    //dataTask
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode == 200) {//请求成功
            //NSData -> JSONData
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //解析（Model：TRWeatjerModel）
            //把提取完的都放到这两个里面
            self.hourlyArray = [self hourlyWeathFromJSON:jsonDic];///////////////
            self.dailyArray = [self dailyWeathFromJSON:jsonDic];///////////////////
            
            //回到主线程reloadDtae
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //更新头部视图
                [self updateHeaderView:jsonDic];
                
                [self.tabkeView reloadData];
            });
        }
        else//失败
        {
            NSLog(@"请求失败:%@",error.userInfo);
        }
    }];
    //启动
    [task resume];
}
-(void)updateHeaderView:(NSDictionary *)jsonDic
{
    //解析头部视图内容
    TRWeatherModel *weathermodel = [TRWeatherModel weatherWithcurrentJSON:jsonDic];
    //更新控件的文本
    self.headerView.cityLabel.text = weathermodel.cityName;
    self.headerView.conditionsLabel.text = weathermodel.weatherDesc;
    self.headerView.temperatureLabel.text = [NSString stringWithFormat:@"%.0f˚",weathermodel.tempforNow];
    self.headerView.hiloLabel.text = [NSString stringWithFormat:@"%.0f˚ / %.0f˚",weathermodel.maxTemp,weathermodel.minTemp];
    //主线程中下(不够严谨)
    NSData *data = [NSData dataWithContentsOfURL:weathermodel.iconURL];
    self.headerView.iconView.image = [UIImage imageWithData:data];
}

#pragma mark -- 解析后的数据存储到数组中
-(NSArray *)hourlyWeathFromJSON:(NSDictionary *)jsonDic
{
    //声明一个可变数组，把临时的存进去
    NSMutableArray *hourlMutableArray = [NSMutableArray array];
    NSArray *hourlyArray = jsonDic[@"data"][@"weather"][0][@"hourly"];
    for (NSDictionary *hourlyDic in hourlyArray) {
        //字典转换成model模型,还要提供一个接口
        TRWeatherModel *hourlyMode = [TRWeatherModel weatherWithHourlyJSON:hourlyDic];
        [hourlMutableArray addObject:hourlyMode];//每次都把解析完的对象都放进可变数组
    }
    return [hourlMutableArray copy];
}
-(NSArray *)dailyWeathFromJSON:(NSDictionary *)jsonDic
{
    //声明一个可变数组
    NSMutableArray *dailyMutableArray = [NSMutableArray array];
    NSArray *dailyArray = jsonDic[@"data"][@"weather"];
    //循环将字典转成模型
    for (NSDictionary *dailyDic in dailyArray) {
        TRWeatherModel *dailyMode = [TRWeatherModel weatherWithdailyJSON:dailyDic];
        [dailyMutableArray addObject:dailyMode];
    }
    return [dailyMutableArray copy];
    //return可变数组
}

-(void)setUpTableView
{
    //添加背景图
    CGRect bounds = self.view.bounds;
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:bounds];
    //bundle里面找这个图片
    self.backgroundImageView.image = [UIImage imageNamed:@"bg.png"];
    [self.view addSubview:self.backgroundImageView];
    
    //创建tableview
    //self.tabkeView = [[UITableView alloc]init];
    self.tabkeView = [UITableView new];
    self.tabkeView.frame = bounds;
    self.tabkeView.backgroundColor = [UIColor clearColor];//清除颜色
    //设置代理
    self.tabkeView.dataSource = self;
    self.tabkeView.delegate = self;
    
    //设置tableview的线的透明度
    self.tabkeView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    //设置分页属性
    self.tabkeView.pagingEnabled = YES;
    //添加到view中
    [self.view addSubview:self.tabkeView];
}

-(void)setUpHeaderView
{
    self.headerView = [[TRWeatherHeadherView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.headerView.backgroundColor = [UIColor clearColor];
    
    //5个空间（4个UILabel，1个UIImageview）
    
    //设置tableview的头部视图
    self.tabkeView.tableHeaderView = self.headerView;
}



#pragma mark -- data source / delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0?self.hourlyArray.count+1:self.dailyArray.count+1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    //设置cell的点击无响应
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Hourly Forecast";
            cell.imageView.image = nil;
            cell.detailTextLabel.text = nil;
        }
        else
        {
            //每个小时
            TRWeatherModel *weatherModel = self.hourlyArray[indexPath.row-1];
            [self configureCell:cell weather:weatherModel cellAtIndexPath:indexPath isHourly:YES];
        }
    }
    else//每天的
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Daily Forecast";
        }
        else
        {
            TRWeatherModel *weatherModel = self.dailyArray[indexPath.row -1];
            [self configureCell:cell weather:weatherModel cellAtIndexPath:indexPath isHourly:NO];
        }
    }
    //cell设置
    //下载图片赋值
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    //自适应的每行的高度
    return [UIScreen mainScreen].bounds.size.height/cellCount;
}

-(void)configureCell:(UITableViewCell *)cell weather:(TRWeatherModel *)weather cellAtIndexPath:(NSIndexPath *)indexPath isHourly:(BOOL)isHourly{
    //isHourly:yes;    //isHourly:no;
    cell.textLabel.text = isHourly?[NSString stringWithFormat:@"%.0f:00",weather.time] : weather.date;
    cell.detailTextLabel.text = isHourly?[NSString stringWithFormat:@"%.0f˚",weather.tempforNow] : [NSString stringWithFormat:@"%.0f˚ / %.0f˚",weather.maxTemp,weather.minTemp];
    
    //设置cell的图片
    //NSString->NSURL->NSData->UIImage
    //下载图片，（耗时，需要放到子线程中）主线程会阻塞
    //NSData *iconData = [NSData dataWithContentsOfURL:weather.iconURL];
    //cell.imageView.image = [UIImage imageWithData:iconData];
    
    //先给定一个占位符图片(避免第一次cell的图片为空)
    //cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    
    //NSOperationQueue *queue = [[NSOperationQueue alloc]init];声明为属性，实现懒加载,防止每次创建cell的时候都调用这个方法，导致每次都创建一个队列
    
    //使用第三方库处理图片缓存
    [cell.imageView sd_setImageWithURL:weather.iconURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
    //图片缓存主逻辑(存在内存中-》字典中)
    //第一次没有图片，执行下载图片操作，下载过程中通过iconURL标识唯一的图片存到字典中，然后再取
//    UIImage *immage = self.imagesDic[weather.iconURL];
//    if (immage) {//不为空，表示内存中已经有了下载的图片
//        cell.imageView.image = immage;
//    }else{//如果内存（字典）为空，就继续往下，从沙盒中取
//        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        if(data){//说明沙盒中有图
//            cell.imageView.image = [UIImage imageWithData:data];
//        }else{//沙盒中没图，内存中也没图
//            //先给定一个占位符图片(避免第一次cell的图片为空)
//            cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
//            //内存中没有下载该图片
//            //再判断一次，内存如果也没，才下
//            //开始下载图片
//            [self downloadImage:weather cell:cell indexPath:indexPath];
//        }
//    }
    
    //placeholder.png 占位图
}
-(void)downloadImage:(TRWeatherModel *)weather cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        //下载图片的操作,在子线程中执行
        NSData *iconData = [NSData dataWithContentsOfURL:weather.iconURL];
        
        //第一次开始下载，把下载下来的图放到字典中（内存中）避免重复下载
        //往字典中缓存
        UIImage *image = [UIImage imageWithData:iconData];
        //通过模型里的url，作为字典里的key，可以唯一标识到对应的immage
        self.imagesDic[weather.iconURL] = image;
        
        //往沙盒中存图片
        NSData *data = UIImagePNGRepresentation(image);
        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];//路径拼接，取最后的url的文件名，和沙盒路径拼接在一起，
        [data writeToFile:filePath atomically:YES];
        
        //回到主线程进行设置cell
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.imageView.image = image;
        }];
    }];
    //发送异步请求（开始下载图片）
    [self.queue addOperation:operation];
}


@end
