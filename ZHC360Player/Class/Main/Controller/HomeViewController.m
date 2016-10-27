//
//  HomeViewController.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//




#import "HomeViewController.h"
#import "PlayerVC.h"
#import "MJRefresh.h"
#import "VideoModel.h"
#import "HomeTableViewCell.h"
#import "DownloadViewController.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,HomeTableViewCellDetailDelagate>

//在线视频tableview
@property (nonatomic, strong) UITableView    *onlineTableView;

//正在下载列表
@property (nonatomic, strong) NSMutableArray *downloadingArr;

//存储模型的数组（在线）
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, getter=isDownloading) BOOL Downloading;

// 记录indexpath
@property (nonatomic, assign) NSIndexPath *selectIndex;

// 记录是否展开
@property (nonatomic, assign) BOOL isExpand;

@end

@implementation HomeViewController

#pragma mark - 懒加载
- (NSMutableArray *)downloadingArr{
    
    if (!_downloadingArr) {
        
        _downloadingArr = [NSMutableArray array];
    }
    return _downloadingArr;
}

- (NSMutableArray *)dataArray{

    if (!_dataArray) {

        _dataArray = [NSMutableArray array];
        NSString *string = [[NSBundle mainBundle] pathForResource:@"testDownload.plist" ofType:nil];
        NSArray *arrTemp = [NSArray arrayWithContentsOfFile:string];

        for (NSDictionary *dict in arrTemp) {

            VideoModel *model = [VideoModel cellModelWithDict:dict];

            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}

#pragma mark - UI
- (void)viewDidLoad {
    
    NSLog(@"%@",NSHomeDirectory());
    
    [super viewDidLoad];
    
    [self setUpUI];
    
    self.navigationController.title = @"在线视频";
    
    [self setupRefresh];
}

- (void)setUpUI{
    
    [self.view setBackgroundColor:ZHColor(51, 52, 53)];
    
    [self.view addSubview:({
        
        self.onlineTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ZHAppWidth, ZHAppHeight - 6) style:UITableViewStylePlain];
        self.onlineTableView.delegate = self;
        self.onlineTableView.dataSource = self;//.dadaSource;
        self.onlineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.onlineTableView.backgroundColor = self.view.backgroundColor;
        self.onlineTableView;
    })];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"recomend_btn_gone"] forBarMetrics:UIBarMetricsDefault];
    [super viewWillAppear:animated];
}

#pragma mark - 刷新部分
- (void)setupRefresh{
    
    self.onlineTableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
}

// 下拉刷新完后，从服务器下载json更新列表
- (void)headerRefresh{
    
    NSLog(@"从服务器更新");
    [self showRefreshDidFinish:NO];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //[coredataManager insertVideos:[NSArray arrayWithContentsOfURL:[NSURL URLWithString:ONLINEPLIST]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.onlineTableView.mj_header endRefreshing];
            [self showRefreshDidFinish:YES];
        });
    });
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

- (BOOL)shouldAutorotate{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark - TableViewDelegate和TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArray.count;
}

//加载cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    VideoModel *cellModel = self.dataArray[indexPath.row];
    //ZHShowTableViewCell *cell = [ZHShowTableViewCell cellWithTableView:tableView withVideoModel:cellModel];
    HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView withVideoModel:cellModel];
    cell.tableview = tableView;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.isExpand && self.selectIndex.row == indexPath.row) {
        return 160;
    }else{
        return 80;
    }
    // return ZHRnmdCellHeight;
}

#pragma mark - tableviewCell的代理

- (void)downloadActionWithModel:(VideoModel *)model{
    
    [[DownloadViewController defaultViewController] addTaskWithVideoModel:model] ? [self.navigationItem.rightBarButtonItem showRedAtOffSetX:0 AndOffSetY:0 OrValue:nil] : NSLog(@"添加失败，已经存在！");
}

- (void)cellDetailButtonClickAtIndexPath:(NSIndexPath *)indexp{
    
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
            HomeTableViewCell *cell = [self.onlineTableView cellForRowAtIndexPath:self.selectIndex];
            [cell resetButtonIcon];
            self.isExpand = YES;
            self.selectIndex = indexp;
        }
    }
    [self.onlineTableView beginUpdates];
    [self.onlineTableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
