//
//  NSObject+keyValue2object.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

/**
 
 1.遍历模型中的属性, 返回属性名数组
 
 2.遍历属性名数组，名作为键值去 寻找字典中 对应的值.
 
 3.找到值后根据模型的属性的类型将值转成正确的类型
 
 4.赋值
 
 */


#import <Foundation/Foundation.h>

@interface NSObject (keyValue2object)

+ (instancetype)objectWithKeyValues:(id)dict;

@end
