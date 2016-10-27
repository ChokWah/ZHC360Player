//
//  ViewController.m
//  下载工具
//
//  Created by 4DAGE_HUA on 16/9/8.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import "DownloadViewController.h"
#import "ZHDownloadTaskManager.h"
#import "ZHDownload.h"
#import "NSString+Hash.h"
#import "PlayerVC.h"
#import "DownloadModel.h"
#import "VideoModel.h"
#import "DownloadTableViewCell.h"
#import "LocationTableViewCell.h"
#import "DBManager.h"

//app的高度
#define AppWidth ([UIScreen mainScreen].bounds.size.width)
//app的宽度
#define AppHeight ([UIScreen mainScreen].bounds.size.height)

@interface DownloadViewController ()<UITableViewDataSource, UITableViewDelegate, DownloadTableViewCellChangeStateDelegate, LocationTableViewCellDetailDelagate>

// 展现下载详情的tableView
@property (strong, nonatomic) UITableView         *downlaodTableView;

// 更新下载状态
@property (strong, nonatomic) NSTimer             *currentTimer;

// 记录indexpath
@property (assign, nonatomic) NSIndexPath         *selectIndex;

// 记录是否展开
@property (assign, nonatomic) BOOL isExpand;

// 记录section的数据数组
@property (strong, nonatomic) NSMutableArray      *sectionDataArray;

// 是否存在下载section
@property (assign, nonatomic) BOOL                isExistDownloadSection;

// 是否存在本地section
@property (assign, nonatomic) BOOL                isExistLocationSection;

@end

@implementation DownloadViewController

#pragma mark - 单例
static DownloadViewController *singletonViewController;
+ (instancetype)defaultViewController{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonViewController = [[DownloadViewController alloc] init];
    });
    return singletonViewController;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonViewController = [super allocWithZone:zone];
    });
    return singletonViewController;
}

- (id)copyWithZone:(NSZone *)zone{
    
    return singletonViewController;
}

#pragma mark - 懒加载
- (NSTimer *)currentTimer{
    
    if (!_currentTimer) {
         _currentTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateArray) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_currentTimer forMode:NSDefaultRunLoopMode];
    }
    return _currentTimer;
}

- (NSMutableArray *)sectionDataArray{
    
    if (!_sectionDataArray) {
        
        _sectionDataArray = [NSMutableArray array];
    }
    return _sectionDataArray;
}

// 恢复持久化数据
- (void)recoverDataFromSqlite{
    
    NSArray *arr = [[DBManager shareTaskManager] queryData];
    if(!arr || arr.count == 0){
        return;
    }
    
    for (NSDictionary *dict in arr) {
        
        VideoModel *videoModel = [VideoModel cellModelWithDict:dict];
        if(videoModel.isDownloading){ // 创建下载section，加入
            
            [self shouldCreateDownloadSection];
            DownloadModel *downloadSectionModel = self.sectionDataArray.firstObject;
            [downloadSectionModel.cellModelsArray addObject:videoModel];
            
        }else if(!videoModel.isDownloading){ // 创建本地section，加入
            
            [self shouldCreateLocationSection];
            DownloadModel *locationSectionModel = self.sectionDataArray.lastObject;
            [locationSectionModel.cellModelsArray addObject:videoModel];
        }
    }
    
}

#pragma mark - UI初始化
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self recoverDataFromSqlite];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置右上角添加任务
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //设置表格
    [self.view addSubview:({
        self.downlaodTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, AppWidth,AppHeight - 6) style:UITableViewStylePlain];
        self.downlaodTableView.delegate = self;
        self.downlaodTableView.dataSource = self;
        self.downlaodTableView.backgroundColor = ZHColor(239, 239, 244);
        self.downlaodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.downlaodTableView;
    })];
}

// 添加下载任务
- (void)rightItemAction{
    
    NSLog(@"多选？");
}

#pragma mark - 增加section代码
- (void)shouldCreateDownloadSection{
    
    if (_isExistDownloadSection) {
        return;
    }
    
    DownloadModel *sectionModel = [[DownloadModel alloc] init];
    sectionModel.sectionType = DownloadSectionTypeDownload;
    _isExistDownloadSection = YES;
    [self.sectionDataArray insertObject:sectionModel atIndex:0];
    [self.downlaodTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)shouldCreateLocationSection{
    
    if (_isExistLocationSection) {
        return;
    }
    //创建本地section
    DownloadModel *locationSectionModel = [[DownloadModel alloc] init];
    locationSectionModel.sectionType = DownloadSectionTypeLocation;
    _isExistLocationSection = YES;
    [self.sectionDataArray addObject:locationSectionModel];
    
}

#pragma mark - TableViewCell数据的增减，更新
- (BOOL)addTaskWithVideoModel:(VideoModel *)model{
    
    if([[ZHDownloadTaskManager shareTaskManager] didExistTask:model.name] || model.path){
        return NO;
    }
    
    @synchronized(self){
        
        // 新增任务，先确定正在下载的section存在，如不在就创建
        [self shouldCreateDownloadSection];
        
        DownloadModel *downloadSectionModel = self.sectionDataArray.firstObject;
        [downloadSectionModel.cellModelsArray addObject:model];
        [[ZHDownloadTaskManager shareTaskManager] addDownloadTask:model.downloadPath toFileName:model.name];
        model.index = downloadSectionModel.cellModelsArray.count;
        BOOL isInsertSuccess = [[DBManager shareTaskManager] insertData:model atIndex:(downloadSectionModel.cellModelsArray.count)];
        [self.downlaodTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"%@",isInsertSuccess ? @"插入成功" : @"插入失败");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(complement:) name:@"complement" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(response:) name:@"response" object:nil];
    
    return YES;
}

// 更新下载进度，状态
- (void)updateArray{
    
    // 1.取出array的下载section
    // 2.判断section内除了被停止外是否有正在下载任务
    // 3.根据判断结果逐个刷新
    
    DownloadModel *downloadSectionModel = [self.sectionDataArray firstObject];
    if(downloadSectionModel.cellModelsArray.count == 0){
        return;
    }
    
    for (int i = 0; i < downloadSectionModel.cellModelsArray.count; i++) {
        
        VideoModel *model = downloadSectionModel.cellModelsArray[i];
        if (model.isDownloading == NO) {
            continue;
        }
        long long tempDataSize = [[ZHDownloadTaskManager shareTaskManager] getDownloadDataSizeWithName:model.name];
        model.tempDataSize = tempDataSize;
        [[DBManager shareTaskManager]updateData:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_downlaodTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
        
    }
}

#pragma mark - NSNotificationCenter通知(分别为下载开始，成功，失败）
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (self.sectionDataArray.count != 0) {
        [self.currentTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.currentTimer setFireDate:[NSDate distantFuture]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)complement:(NSNotification *)notification{
    
    NSDictionary *dict = notification.userInfo;
    NSError *error = [dict objectForKey:@"error"];
    
    if (error) {
        NSString *errorString = [NSString stringWithFormat:@"error:%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        [self updateArrayInfoWithName:notification.object andInfo:@{@"error" : errorString}];
        return;
    }
    
    [[ZHDownloadTaskManager shareTaskManager] completeWithTaskName:[notification.userInfo objectForKey:@"name"]];
    [self updateArrayInfoWithName:notification.object andInfo:notification.userInfo];
}

- (void)response:(NSNotification *)notification{
    
    //这里字典是空的，取出来的东西都是空，但是就默认为0
    NSDictionary *dict = notification.userInfo;
    
    DownloadModel *downloadSectionModel = self.sectionDataArray.firstObject;
    VideoModel *model = downloadSectionModel.cellModelsArray[[notification.object integerValue]];
    if(!model && !notification.userInfo[@"size"]){
        return;
    }
    model.totalSize = [dict[@"size"] longValue];
    model.isDownloading = YES;
    //开始每秒更新
    [self.currentTimer setFireDate:[NSDate distantPast]];
    
}


#pragma mark - 完成后更新 , 考虑是否需要加锁
- (void)updateArrayInfoWithName:(NSString *)indexString andInfo:(NSDictionary *)info{

    //取出模型
    DownloadModel *downloadSectionModel = self.sectionDataArray.firstObject;
    VideoModel *model = downloadSectionModel.cellModelsArray[[indexString integerValue]];
    NSString *errorStirng = [info objectForKey:@"error"];
    if (!model) {
        NSLog(@"模型不存在");
        return;
    }
    
    if(errorStirng){
        
        model.progressInfo = errorStirng;
        
    }else{
        
        model.tempDataSize = model.totalSize;
        [model setIsDownloading:NO];
        model.path = [info objectForKey:@"path"];
        model.progressInfo = @"100%";
        //获取系统当前时间
        NSDate *currentDate = [NSDate date];
        //用于格式化NSDate对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设置格式：zzz表示时区
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        //NSDate转NSString
        model.dateString = [dateFormatter stringFromDate:currentDate];
        
        [[DBManager shareTaskManager] updateData:model];
        
        [self shouldCreateLocationSection];
        
        DownloadModel *locationSectionModel = self.sectionDataArray.lastObject;
        [locationSectionModel.cellModelsArray addObject:model];
        //[downloadSectionModel.cellModelsArray removeObject:model];
        
        if ([downloadSectionModel didEmptyAfterRemoveObjectInCellModelsArray:model]) {
            
            //删除正在下载的section
            [self.sectionDataArray removeObjectAtIndex:0];
            _isExistDownloadSection = NO;
        }
    }

    //NSArray *arr =  [[DBManager shareTaskManager] queryData];
    //NSLog(@"===%@",arr);
    //请完成程序启动就搜索数据库，还原数据到控制器（副线程，控制器是单例）
    
    
    if (![[ZHDownloadTaskManager shareTaskManager] didDownloadingTask] && self.currentTimer.isValid == YES) {
        // 停止更新
        [self.currentTimer setFireDate:[NSDate distantFuture]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_downlaodTableView reloadData];
    });
}


#pragma mark - UITableView 代理方法
// 左滑出现Delete按钮的功能
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 删除模型
    DownloadModel *sectionModel = [self.sectionDataArray objectAtIndex:indexPath.section];
    VideoModel *cellModel = sectionModel.cellModelsArray[indexPath.row];
    if ([sectionModel didEmptyAfterRemoveObjectInCellModelsArrayIndex:indexPath.row]) {
        [self.sectionDataArray removeObjectAtIndex:0];
        _isExistDownloadSection = NO;
    }
    [[ZHDownloadTaskManager shareTaskManager] removeDownloadTaskName:cellModel.name];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}


//设置tableview是否可编辑
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isExistDownloadSection && self.sectionDataArray.count == 2 && indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }else if(_isExistDownloadSection && self.sectionDataArray.count == 1){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// 修改Delete按钮文字为 “删除”
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}


// 沃日泥马，这个才是组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    NSLog(@"一共 %lu 组",self.sectionDataArray.count);
    return self.sectionDataArray.count;
}

// 每一组内有多少个sell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    DownloadModel *model = self.sectionDataArray[section];
    NSLog(@"第 %lu 组有 %lu 行",section,model.cellModelsArray.count);
    return model.cellModelsArray.count;
}

// header的title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    DownloadModel *model = self.sectionDataArray[section];
    return model.sectionTitil;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 找到对应的section组
    DownloadModel *model = self.sectionDataArray[indexPath.section];
    NSLog(@"cellForRowAtIndexPath 方法 :%lu 组，%lu行",indexPath.section,indexPath.row);
    
    // 取出组内模型
    VideoModel *cellModel = model.cellModelsArray[indexPath.row];
    
    if (model.sectionType == DownloadSectionTypeLocation) {
        
        LocationTableViewCell *cell = [LocationTableViewCell cellWithTableView:tableView andModel:cellModel];
        cell.delegate = self;
        cell.tableview = tableView;
        return cell;

    }else{
        
        DownloadTableViewCell *cell = [DownloadTableViewCell cellWithTableView:tableView andDownloadModel:cellModel];
        cell.delegate = self;
        cell.tableview = tableView;
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 找到对应的section组, 取出模型
    DownloadModel *model = self.sectionDataArray[indexPath.section];
    VideoModel *cellModel = model.cellModelsArray[indexPath.row];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cellModel.path]) {
        
        PlayerVC *player = [[PlayerVC alloc]initWithVideoName:[NSURL URLWithString:cellModel.path]];
        [self.navigationController pushViewController:player animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    // 下载section不改变高度
    if (_isExistDownloadSection && self.sectionDataArray.count == 2 && indexPath.section == 0) {
        return 80;
    }else if(_isExistDownloadSection && self.sectionDataArray.count == 1){
        return 80;
    }
    
    // 本地section根据按钮改变高度，显示更多
    if (self.isExpand && self.selectIndex.row == indexPath.row) {
        return 160;
    }else{
        return 80;
    }
    //return 80;
}

#pragma mark - 自定义Cell的代理方法
// cell的暂停，恢复按钮
- (void)cellChangeStateAtIndexPath:(NSIndexPath *)indexp{
    
    DownloadModel *model = self.sectionDataArray[indexp.section];
    VideoModel *cellModel = model.cellModelsArray[indexp.row];
    
    if(cellModel.isDownloading){
        
        [[ZHDownloadTaskManager shareTaskManager] suspendDownloadTaskName:cellModel.name];
        [self.currentTimer setFireDate:[NSDate distantFuture]];
        cellModel.isDownloading = NO;
    }else{
        
        [[ZHDownloadTaskManager shareTaskManager] resumeDownloadTaskName:cellModel.name];
        [self.currentTimer setFireDate:[NSDate distantPast]];
        cellModel.isDownloading = YES;
    }
    [self.downlaodTableView beginUpdates];
    [self.downlaodTableView endUpdates];
    NSLog(@"任务 %@ 状态：%@",cellModel.name,cellModel.isDownloading ? @"下载中" : @"暂停中");
}

// 实现 cell 的按钮事件代理方法，把cell的行数传过来，刷新当前行数的高度
- (void)cellButtonClickAtIndexPath:(NSIndexPath *)indexp{
    
    if (!self.selectIndex) {
        
        self.isExpand = YES;
        self.selectIndex = indexp;
        
    }else{
        
        // 先改正当前indexpath的长度为80
        self.isExpand = NO;
        
        // 再判断当前indexPath是否跟已展开的index一致，如果是，则置空已展开index，如果不是，则改正当前indexpath长度为160，把当前index赋值给已展开index
        if(indexp == self.selectIndex){
            self.selectIndex = nil;
        }else{
            LocationTableViewCell *cell = [self.downlaodTableView cellForRowAtIndexPath:self.selectIndex];
            [cell resetButtonIcon];
            self.isExpand = YES;
            self.selectIndex = indexp;
        }
    }
    [self.downlaodTableView beginUpdates];
    [self.downlaodTableView endUpdates];
}

// 移除本地的文件
- (void)removeButtonClickActionAtIndexPath:(NSIndexPath *)indexp{

    DownloadModel *model = self.sectionDataArray[indexp.section];
    VideoModel *cellModel = model.cellModelsArray[indexp.row];
    if ([model didEmptyAfterRemoveObjectInCellModelsArray:cellModel]) {
        
        if (_isExistDownloadSection && _isExistLocationSection) {
            [self.sectionDataArray removeObjectAtIndex:1];
        }else{
            
            [self.sectionDataArray removeObjectAtIndex:0];
        }
        _isExistLocationSection = NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:cellModel.path error:nil];
    [self.downlaodTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
