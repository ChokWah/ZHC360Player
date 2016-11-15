//
//  VideoDetailView.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/11/4.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;

@protocol  VideoDetailViewDelegate <NSObject>

- (void)playVideoAction:(NSString *)name;

@end

@interface VideoDetailView : UIView

@property (nonatomic, weak) id<VideoDetailViewDelegate> delegate;

- (instancetype)initWithVideoModel:(VideoModel *)model;

//+ (instancetype)detailviewWithName:(NSString *)name andImage:(NSString *)imgstring;

@end
