//
//  HomeViewController.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//


#import "HomeViewController.h"
#import "MJRefresh.h"
#import "VideoModel.h"
#import "HomeTableViewCell.h"
#import "ZHDownloadTaskManager.h"
#import "VideoDetailView.h"
#import "AFNetworking.h"
#import "HTY360PlayerVC.h"


@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource, VideoDetailViewDelegate, HomeTableViewCellDetailDelagate>

// 在线视频tableview
@property (nonatomic, strong) UITableView    *homeTableView;

// 存储模型的数组
@property (nonatomic, strong) NSMutableArray <VideoModel *> *dataArray;

// 以name ： index存储正在下载的任务及对应的序号
@property (nonatomic, strong) NSMutableDictionary *downloadDict;

// 更新下载状态
@property (strong, nonatomic) NSTimer *currentTimer;

@end

@implementation HomeViewController

#pragma mark - 懒加载
- (NSTimer *)currentTimer{
    
    if (!_currentTimer) {
        _currentTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_currentTimer forMode:NSDefaultRunLoopMode];
    }
    return _currentTimer;
}

- (NSMutableArray *)dataArray{

    if (!_dataArray) {

        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableDictionary *)downloadDict{
    
    if (!_downloadDict) {
        
        _downloadDict = [NSMutableDictionary dictionary];
    }
    return _downloadDict;
}

#pragma mark - UI
- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    
    [self setUpUI];
    [self setupRefresh];
    [self headerRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyDownload:) name:@"readyDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(complement:) name:@"complement" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(response:) name:@"response" object:nil];
}

- (void)setUpUI{
    
    [self.view setBackgroundColor:ZHColor(51, 52, 53)];
    
    [self.view addSubview:({
        
        self.homeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ZHAppWidth, ZHAppHeight - 6) style:UITableViewStylePlain];
        self.homeTableView.delegate = self;
        self.homeTableView.dataSource = self;//.dadaSource;
        self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.homeTableView.backgroundColor = self.view.backgroundColor;
        self.homeTableView;
    })];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"recomend_btn_gone"] forBarMetrics:UIBarMetricsDefault];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.currentTimer setFireDate:[NSDate distantFuture]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"response" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"complement" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"readyDownload" object:nil];
    
}

#pragma mark - 下拉刷新部分
- (void)setupRefresh{
    
    self.homeTableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
}

// 下拉刷新完后，从服务器下载json更新列表
- (void)headerRefresh{
    
    NSLog(@"从服务器更新");
    __weak __typeof(self)weakSelf = self;
    [self showRefreshDidFinish:NO];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self loadAllDataWithBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.homeTableView.mj_header endRefreshing];
                [weakSelf showRefreshDidFinish:YES];
                [weakSelf.homeTableView reloadData];
            });
        }];
        
    });
}

// 从数据库，网上更新
- (void)loadAllDataWithBlock:(void(^)())block{
    
    __weak __typeof(self)weakSelf = self;
    
    NSArray *arr = [ZHDBMANAGER queryDataWithName:TABLENAME];
    if (arr != nil && arr.count != 0 && [arr isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dict in arr) {
            
            VideoModel *model = [VideoModel cellModelWithDict:dict];
            [self.dataArray addObject:model];
        }
    }
    
    [self downloadNewPlistWithBlock:^(NSURL *fileUrl) {
        
        NSArray *arrTemp = [NSArray arrayWithContentsOfURL:fileUrl];
        for (NSDictionary *dict in arrTemp) {
            
            VideoModel *model = [VideoModel cellModelWithDict:dict];
            if (weakSelf.dataArray.count != 0) {
                
                [weakSelf.dataArray enumerateObjectsUsingBlock:^(VideoModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    if (![obj.name isEqualToString:model.name]) {
                        model.index = weakSelf.dataArray.count;
                        [weakSelf.dataArray addObject:model];
                        *stop = YES;
                    }
                }];
            }else{
                
                [weakSelf.dataArray addObject:model];
            }
            
        }
        block();
    }];
}

// 从服务器下载plist列表
- (void)downloadNewPlistWithBlock:(void(^)(NSURL *fileUrl))result{
    
    AFHTTPSessionManager *afmanager = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:PlistLink]];
    NSURLSessionDownloadTask *task = [afmanager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        //return [NSURL URLWithString:ZHDocumentFilePath(@"testDownload.plist")];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showError:error.debugDescription];
        }
        result(filePath);
    }];
    [task resume];
}

// 显示提示框
- (void)showRefreshDidFinish:(BOOL)didFinish{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hide:YES];
    didFinish ? ({
        
        [MBProgressHUD showSuccess:@"刷新成功"];
        [hud hide:YES];
        
    }) : ({
        
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"更新中";
        [hud hide:NO];
    });
    
}

#pragma mark - NSTimeer：每秒刷新进度
// 每秒更新进度
- (void)updateProgress{
    
    if(![ZHDWMANAGER isTaskDownloading] || self.downloadDict.count == 0){
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.downloadDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        VideoModel *model = [weakSelf getModelWithName:key];
        if(model.isDownloading){
            //model.tempDataSize = ZHGETCacheFileLength(model.name) / 1024;
            model.tempDataSize = [ZHDWMANAGER getDownloadDataSizeWithName:model.name];
            NSLog(@"更新%@ : 大小 %lu",model.name,(unsigned long)model.tempDataSize);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_homeTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([obj unsignedIntegerValue]-1) inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
        
    }];
  /*
    for (int i = 0; i < self.downloadIndexArr.count; i++) {
        
        NSUInteger index = [self.downloadIndexArr[i] unsignedIntegerValue];
        VideoModel *model = self.dataArray[index];
        if(!model.isDownloading){
            continue;
        }
        NSLog(@"更新%@",model.name);
        model.tempDataSize = ZHGETCacheFileLength(model.name) / 1024;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_homeTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
   */
}

// 强制竖屏
- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

// 强制竖屏
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark - NSNotification
// 任务下载完成
- (void)complement:(NSNotification *)notification{
    
    NSDictionary *dict = notification.userInfo;
    NSError *error     = notification.object;
    
    if (error) {
        NSLog(@"Viewcontroller ：%@",[NSString stringWithFormat:@"error:%@",error.description]);
        return;
    }
    
    VideoModel *model = [self getModelWithName:[dict objectForKey:@"name"]];
    if(!model){
        return;
    }
    [model setPath:[dict objectForKey:@"path"]];
    [model setTempDataSize:model.totalSize];
    [model setIsDownloading:NO];
    [model setIsReadyDownload:NO];
    [ZHDBMANAGER insertData:model WithName:TABLENAME]; //下载完成进行本地持久化
    [ZHDWMANAGER isTaskDownloading] ? nil : [self.currentTimer setFireDate:[NSDate distantFuture]];
    [self.downloadDict.allKeys containsObject:model.name] ? [self.downloadDict removeObjectForKey:model.name] : nil;
    //完成下载的显示
    dispatch_async(dispatch_get_main_queue(), ^{
        [_homeTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    });
}

// 任务开始响应
- (void)response:(NSNotification *)notification{
    
    NSDictionary *dict = notification.userInfo;

    VideoModel *model = [self getModelWithName:[dict objectForKey:@"name"]];
    if(!model){
        return;
    }
    [model setTotalSize:[dict[@"size"] unsignedIntegerValue]];
    [model setIsDownloading:YES];
    [model setIsReadyDownload:NO];
    //开始每秒更新
    [self.currentTimer setFireDate:[NSDate distantPast]];
    NSLog(@"response : %@",model.name);
}

- (VideoModel *)getModelWithName:(NSString *)name{
    
    if (![self.downloadDict.allKeys containsObject:name]) {
        return nil;
    }
    
    NSUInteger index = [[self.downloadDict objectForKey:name] unsignedIntegerValue];
    VideoModel *model = self.dataArray[index-1];
    return model;
}

- (void)readyDownload:(NSNotification *)notification{
    
    NSUInteger dwCout = [notification.object unsignedIntegerValue];
    
    for (VideoModel *model in self.dataArray) {
        
        if(model.isReadyDownload == YES && model && dwCout > 0){
            [self downloadFileWithModel:model];
            dwCout--;
        }
    }
}

#pragma mark - 代理：TableViewDelegate和TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArray.count;
}

//加载cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    VideoModel *cellModel = self.dataArray[indexPath.row];
    cellModel.index = indexPath.row;
    HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView withVideoModel:cellModel];
    cell.delegate = self;
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return ZHRnmdCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoModel *cellModel = self.dataArray[indexPath.row];
    NSLog(@"选择 ：%@",cellModel.name);
    ([self isFileExistWithModel:cellModel]) ? [self showDetailViewWithModel:cellModel] : [self downloadFileWithModel:cellModel];
}

#pragma mark - 下载or播放视频

- (void)stopDownloadAction:(NSUInteger)indexp{
    
    VideoModel *model = [self.dataArray objectAtIndex:indexp];
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"正在下载" message:@"是否取消下载" preferredStyle:UIAlertControllerStyleAlert];
    // 设置按钮
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [ZHDWMANAGER removeDownloadTaskName:model.name] ? [weakSelf cancelDownloadWithName:model.name] : nil;
    }];
    
    [alert addAction:cancel];
    [alert addAction:defult];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)showDetailViewWithModel:(VideoModel *)model{
    
    if ([self.view.subviews.lastObject isKindOfClass:[VideoDetailView class]]) {
        [self.view.subviews.lastObject removeFromSuperview];
    }
    
    VideoDetailView *showView = [[VideoDetailView alloc]initWithVideoModel:model];
    showView.delegate = self;
    [self.view addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ZHAppWidth-40, ZHAppHeight/4));
        make.top.equalTo(self.view.mas_top).with.offset(ZHAppHeight/5);
    }];
}

// 播放视频
- (void)playVideoAction:(NSString *)name{
    
    if ([ZHFILEMANAGER fileExistsAtPath:ZHDocumentFilePath(name)]) {
        
        HTY360PlayerVC *videoController = [[HTY360PlayerVC alloc] initWithNibName:@"HTY360PlayerVC"
                                                                           bundle:nil
                                                                              url:[NSURL fileURLWithPath:ZHDocumentFilePath(name)]];
        if (![[self presentedViewController] isBeingDismissed]) {
            [self presentViewController:videoController animated:YES completion:nil];
        }
    }
}

// 下载或者取消下载
- (void)downloadFileWithModel:(VideoModel *)cellModel{
    
    if (cellModel.isDownloading) {
        return;
    }
    
    BOOL alreadyDownload      = [ZHDWMANAGER addDownloadTaskWithModel:cellModel];
    [self.downloadDict setObject:@([self.dataArray indexOfObject:cellModel]+1) forKey:cellModel.name];
    cellModel.isDownloading   = alreadyDownload;
    cellModel.isReadyDownload = !alreadyDownload;
}

- (void)cancelDownloadWithName:(NSString *)name{
    
    VideoModel *cellModel = [self getModelWithName:name];
    cellModel.isDownloading   = NO;
    cellModel.isReadyDownload = NO;
}


- (BOOL)isFileExistWithModel:(VideoModel *)model{
    
    return ([ZHFILEMANAGER fileExistsAtPath:ZHDocumentFilePath(model.name)] && model.path && !model.isDownloading && !model.isReadyDownload);
}

- (void)dealloc{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
