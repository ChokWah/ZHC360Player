//
//  UITableView+tableViewType.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/25.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "UITableView+tableViewType.h"

@implementation UITableView (tableViewType)

//@dynamic tableViewType;
@dynamic tableviewType;


//static char typeKey;
static char key;

//- (void)setTableViewType:(NSString *)tableViewType{
//    
//    objc_setAssociatedObject(self, &typeKey, tableViewType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSString *)tableViewType{
//    
//    return objc_getAssociatedObject(self, &typeKey);
//}


- (void)setTableviewType:(zh_TableViewType)tableviewType{
    
    NSString *temp = (tableviewType == zh_TableViewTypeOnline) ? @"online": @"local";
    
    objc_setAssociatedObject(self, &key, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (zh_TableViewType)tableviewType{
    
    NSString *temp = objc_getAssociatedObject(self, &key);
    
    return [temp isEqualToString:@"online"] ? zh_TableViewTypeOnline : zh_TableViewTypeLocal;
}

@end
