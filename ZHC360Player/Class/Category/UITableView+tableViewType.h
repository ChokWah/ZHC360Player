//
//  UITableView+tableViewType.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/25.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, zh_TableViewType){
    
    zh_TableViewTypeOnline = 0,
    zh_TableViewTypeLocal
};

@interface UITableView (tableViewType)

//@property (nonatomic, strong) NSString *tableViewType;

@property (nonatomic, assign) zh_TableViewType tableviewType;
@end
