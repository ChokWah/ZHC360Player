//
//  ZHProperty.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHPropertyType.h"

@interface ZHProperty : NSObject

/** 成员属性名字*/
@property (nonatomic, readonly) NSString *name;

/** 成员属性的类型 */
@property (nonatomic, readonly) ZHPropertyType *type;

+ (instancetype)propertyWithProperty:(objc_property_t)property;

@end
