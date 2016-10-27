//
//  ZHPropertyType.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHPropertyType : NSObject

/** 是否为id类型*/
@property (nonatomic, readonly,getter=isIdType)     BOOL idType;

/** 是否为基本数字类型*/
@property (nonatomic, readonly,getter=isNumberType) BOOL numberType;

/** 是否为类型*/
@property (nonatomic, readonly,getter=isBoolType)   BOOL boolType;

/** 对象类型*/
@property (nonatomic, readonly) Class typeClass;

+ (instancetype)propertyTypeWithAttributeString:(NSString *)string;

@end
