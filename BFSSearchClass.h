//
//  BFSSearchClass.h
//  调用示例：
//       [BFSSearchClass searchClass:@"UIImageView" inClass:@"UIButton" inSuperClass:NO maxCount:-1];
//
//  Created by CRMO on 2018/7/29.
//  Copyright © 2018年 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFSSearchClass : NSObject

/**
 用BFS从根类逐层遍历类成员变量、属性，寻找指定的类

 @param target 需要查找类
 @param from 开始查找的根类
 */
+ (void)searchClass:(NSString *)target inClass:(NSString *)from;

/**
 用BFS从根类逐层遍历类成员变量、属性，寻找指定的类

 @param target 需要查找类
 @param from 开始查找的根类
 @param inSuperClass 是否在父类查找
 @param max 最大查询次数
 */
+ (void)searchClass:(NSString *)target
            inClass:(NSString *)from
       inSuperClass:(BOOL)inSuperClass
           maxCount:(int)max;

@end
