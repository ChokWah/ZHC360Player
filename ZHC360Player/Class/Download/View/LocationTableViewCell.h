//
//  LocationTableViewCell.h
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/12.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;

@protocol LocationTableViewCellDetailDelagate <NSObject>

/** 显示更多 */
- (void)cellButtonClickAtIndexPath:(NSIndexPath *)indexp;

/** 删除该文件操作*/
- (void)removeButtonClickActionAtIndexPath:(NSIndexPath *)indexp;
@end


@interface LocationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel  *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel  *dateLabel;

@property (strong, nonatomic) IBOutlet UIButton *moreDetailButton;

@property (strong, nonatomic) IBOutlet UIButton *removeButton;

/** 是否展开*/
@property (assign, nonatomic) BOOL isExpand;

/** 用于在cell内部获取行数*/
@property (weak  , nonatomic) UITableView *tableview;

/** 委托，对cell的操作*/
@property (weak  , nonatomic)  id<LocationTableViewCellDetailDelagate> delegate;

+ (LocationTableViewCell *)cellWithTableView:(UITableView *)tableview andModel:(VideoModel *)model;

- (void)resetButtonIcon;

@end
