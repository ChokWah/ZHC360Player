//
//  NSObject+keyValue2object.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "NSObject+keyValue2object.h"
#import "ZHProperty.h"
#import "ZHPropertyType.h"

@implementation NSObject (keyValue2object)

+ (instancetype)objectWithKeyValues:(id)dict{
    
    if (!dict) {
        return nil;
    }
    
    return [[[self alloc]init] setKeyValues:dict];
}

- (instancetype)setKeyValues:(id)dict{
    
    // 1. 获得属性名字的数组
    NSArray *propertiesArray = [self.class properties];
    
    // 2. 遍历取出数组的属性名字（downloadPath...）
    for (ZHProperty *property in propertiesArray) {
        
        // 3. 以每一个属性名字为key 取出 字典的value
        ZHPropertyType *type = property.type;
        id value = [dict valueForKey:property.name];
        if (!value) continue;
        
        // 4. 根据模型属性的类型，把value转成为正确的类型
        if (type.isBoolType) {
            
            //[value isEqual:@0] ? (value = @NO) : (value = @YES);
    
        }else if(type.isIdType){
            
            NSLog(@"ID");
            
        }else if(type.isNumberType){
            
            // 字符串->数字
            if ([value isKindOfClass:[NSString class]])
            value = [[[NSNumberFormatter alloc]init] numberFromString:value];
            
        }else{
            
            if (type.typeClass == [NSString class]) {
                
                if ([value isKindOfClass:[NSNumber class]]) {
                    if (type.isNumberType)
                    // NSNumber -> NSString
                    value = [value description];
                }else if ([value isKindOfClass:[NSURL class]]){
                    // NSURL -> NSString
                    value = [value absoluteString];
                }
            }
        }
        
        // 5. 赋值
        [self setValue:value forKey:property.name];
    }
    
    return self;
}
@end
