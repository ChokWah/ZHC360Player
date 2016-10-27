//
//  ZHPropertyType.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "ZHPropertyType.h"

/**
 *  成员变量类型（属性类型）
 */
NSString *const MJPropertyTypeInt = @"i";
NSString *const MJPropertyTypeShort = @"s";
NSString *const MJPropertyTypeFloat = @"f";
NSString *const MJPropertyTypeDouble = @"d";
NSString *const MJPropertyTypeLong = @"q";
NSString *const MJPropertyTypeChar = @"c";
NSString *const MJPropertyTypeBOOL1 = @"c";
NSString *const MJPropertyTypeBOOL2 = @"b";
NSString *const MJPropertyTypePointer = @"*";

NSString *const MJPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const MJPropertyTypeMethod = @"^{objc_method=}";
NSString *const MJPropertyTypeBlock = @"@?";
NSString *const MJPropertyTypeClass = @"#";
NSString *const MJPropertyTypeSEL = @":";
NSString *const MJPropertyTypeId = @"@";

@implementation ZHPropertyType

+ (instancetype)propertyTypeWithAttributeString:(NSString *)string{
    
    return [[ZHPropertyType alloc]initWithTypeString:string];
}

- (instancetype)initWithTypeString:(NSString *)string{
    
    if (self = [super init]) {
        
        NSUInteger loc = 1;
        NSUInteger len = [string rangeOfString:@","].location - loc;
        NSString *type = [string substringWithRange:NSMakeRange(loc, len)];
        [self getTypeCode:type];
    }
    return self;
}

- (void)getTypeCode:(NSString *)code{
    
    if ([code isEqualToString:MJPropertyTypeId]) {
        
        _idType = YES;
        
    }else if(code.length > 3 && [code hasPrefix:@"@\""]){
        
        //去掉@“ 和 ”，截取中间的类型名称
        code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(code);
        _numberType = (_typeClass == [NSNumber class] || [_typeClass isSubclassOfClass:[NSNumber class]]);
    }
    
    // 是否为数字类型
    NSString *lowerCode   = code.lowercaseString; //改为小写
    NSArray  *numberTypes = @[MJPropertyTypeInt, MJPropertyTypeShort, MJPropertyTypeFloat, MJPropertyTypeDouble, MJPropertyTypeLong];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
    }
    
    if ([lowerCode isEqualToString:MJPropertyTypeBOOL1] || [lowerCode isEqualToString:MJPropertyTypeBOOL2]) {
        
        _boolType = YES;
    }
}
@end
