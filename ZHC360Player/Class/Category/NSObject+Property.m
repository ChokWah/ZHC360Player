//
//  NSObject+Property.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>
#import "ZHProperty.h"

typedef struct property_t {
    const char *name;
    const char *attributes;
} *propertyStruct;

@implementation NSObject (Property)

+ (NSArray *)properties{
    
    NSMutableArray *propertiesArray = [NSMutableArray array];
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &outCount);
    
    // 封装一个类ZHProperty，存储属性名字和属性的类型
    for (int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        // NSLog(@"name:%s---attributes:%s",((propertyStruct)property)->name,((propertyStruct)property)->attributes);
        ZHProperty *propertyObj = [ZHProperty propertyWithProperty:property];
        [propertiesArray addObject:propertyObj];
    }
    
    return propertiesArray;
}
@end
