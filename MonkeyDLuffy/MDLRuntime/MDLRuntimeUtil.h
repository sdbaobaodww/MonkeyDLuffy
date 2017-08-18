//
//  MDLRuntimeUtil.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface MDLRuntimeUtil : NSObject

/**
 获取属性结构体
 @param klass 指定的类
 @param propertyName 属性名称
 @return objc_property_t
 */
+ (objc_property_t)getPropertyForClass:(Class)klass propertyName:(NSString *)propertyName;

/**
 获取属性对应的类或者协议，如果该属性定义不是类或者协议则返回nil
 @param property 属性结构体
 @return 该属性对应的类或者协议
 */
+ (NSString *)getClassOrProtocolForProperty:(objc_property_t)property;

@end
