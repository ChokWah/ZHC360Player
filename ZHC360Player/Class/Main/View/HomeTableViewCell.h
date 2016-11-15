//
//  HomeTableViewCell.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/4/28.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;

@protocol HomeTableViewCellDetailDelagate <NSObject>

- (void)stopDownloadAction:(NSUInteger)indexp;

@end

@interface HomeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *backGoundImageView;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *adressLabel;

@property (weak,   nonatomic) id<HomeTableViewCellDetailDelagate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView withVideoModel:(VideoModel *)model;

- (void)updateProgress:(CGFloat)progress;
@end
