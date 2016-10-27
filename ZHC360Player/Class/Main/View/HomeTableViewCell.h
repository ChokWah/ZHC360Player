//
//  HomeTableViewCell.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/8.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;

@protocol HomeTableViewCellDetailDelagate <NSObject>

- (void)cellDetailButtonClickAtIndexPath:(NSIndexPath *)indexp;

- (void)downloadActionWithModel:(VideoModel *)model;

@end


@interface HomeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *backGoundImageView;

@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UIButton *downloadButton;

@property (strong, nonatomic) IBOutlet UIButton *moreOperationsButton;

/** 是否展开*/
@property (assign, nonatomic) BOOL isExpand;

@property (weak, nonatomic) id<HomeTableViewCellDetailDelagate> delegate;

/** 用于在cell内部获取行数*/
@property (weak  , nonatomic) UITableView *tableview;

+ (instancetype)cellWithTableView:(UITableView *)tableView withVideoModel:(VideoModel *)model;

- (void)resetButtonIcon;
@end
