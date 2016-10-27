//
//  ZHProperty.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "ZHProperty.h"

@implementation ZHProperty

+ (instancetype)propertyWithProperty:(objc_property_t)property{
    
    return [[ZHProperty alloc]initWithProperty:property];
}

// 封装一个类ZHPropertyType - 模型所有属性的类型
// 标明是否为数字，布尔值，自定义class，id类型
- (instancetype)initWithProperty:(objc_property_t)property{
    
    if (self = [super init]) {
        _name = @(property_getName(property));
        _type = [ZHPropertyType propertyTypeWithAttributeString:@(property_getAttributes(property))];
    }
    return self;
}
@end
