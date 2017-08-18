//
//  MDLIOCRegister.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOCBean.h"

/**
 IOC上下文，上下文的作用：1，缓存所有的注入Bean；2，保存全局以及模块作用域生成的注入对象；3，提供供模块使用的批量创建、删除实例方法
 */
@interface MDLIOCContext : NSObject

/**
 @param scope 注入对象作用范围
 @return 不同作用范围缓存的注入对象
 */
- (NSDictionary *)cachesWithScope:(MDLIOCScope)scope;

/**
 @return 所有的注入Bean
 */
- (NSDictionary *)allBeans;

/**
 注册注入Bean
 @param bean IOC注入描述对象
 @param beanKey BeanKey
 */
- (void)registerBean:(MDLIOCBean *)bean forKey:(id <NSCopying>)beanKey;

/**
 获取注入对象，如果该BeanKey未注册过，则返回nil。
 1，全局作用域第一次调用的时候创建，创建后只要上下文未释放就会一直存在；
 2，模块作用域对象则需要在进入模块的时候统一进行创建，创建后会进行缓存，在退出模块的时候统一进行释放；
 3，正常作用域对象每次调用时都会创建，并且不会缓存；
 
 @param beanKey BeanKey
 @return 生成的实例
 */
- (id)instanceForKey:(id <NSCopying>)beanKey;

/**
 批量创建实例
 @param beanKeys BeanKey集合
 */
- (void)batchCreateInstanceForKeys:(NSArray *)beanKeys;

/**
 批量删除实例
 @param beanKeys BeanKey集合
 */
- (void)batchRemoveInstanceForKeys:(NSArray *)beanKeys;

#pragma mark - Subscripting

- (MDLIOCBean *)objectForKeyedSubscript:(id <NSCopying>)key;

- (void)setObject:(MDLIOCBean *)anObject forKeyedSubscript:(id <NSCopying>)aKey;

@end
