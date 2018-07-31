//
//  BFSSearchClass.m
//
//  Created by CRMO on 2018/7/29.
//  Copyright © 2018年 crmo. All rights reserved.
//

#import "BFSSearchClass.h"
#import <objc/runtime.h>

@interface BFSSearchNode : NSObject
/** 节点类名 **/
@property (copy, nonatomic) NSString *className;
/** 变量名 **/
@property (copy, nonatomic) NSString *ivarName;
/** 父节点 **/
@property (strong, nonatomic) BFSSearchNode *preNode;
@end

@implementation BFSSearchNode
@end

@implementation BFSSearchClass

+ (void)searchClass:(NSString *)target inClass:(NSString *)from {
    [self searchClass:target inClass:from inSuperClass:YES maxCount:-1];
}

+ (void)searchClass:(NSString *)target
            inClass:(NSString *)from
       inSuperClass:(BOOL)inSuperClass
           maxCount:(int)max {
    // 遍历队列
    NSMutableArray *nodeQueue = [NSMutableArray array];
    // 存储已经遍历过的类
    NSMutableSet *searchedMap = [NSMutableSet set];
    // 初始化根节点
    BFSSearchNode *rootNode = [[BFSSearchNode alloc] init];
    rootNode.className = from;
    rootNode.preNode = nil;
    rootNode.ivarName = @"r=Root Class";
    [nodeQueue addObject:rootNode];
    
    int searchCount = 0;
    
    while (nodeQueue.count != 0) {
        if (searchCount == max) {
            break;
        }
        searchCount++;

        BFSSearchNode *node = [nodeQueue firstObject];
        [nodeQueue removeObjectAtIndex:0];
        
        if ([searchedMap containsObject:node.className]) { // 搜索过，剪枝
            continue;
        } else {
            [searchedMap addObject:node.className];
        }
        
//        NSLog(@"查找中---【%@】", node.className);
        
        Class class = objc_getClass(node.className.UTF8String);

        if (inSuperClass) {
            // 遍历父类，加入遍历队列
            Class superClass = [class superclass];
            while (superClass) {
                BFSSearchNode *superNode = [[BFSSearchNode alloc] init];
                superNode.className = [NSString stringWithCString:class_getName(superClass) encoding:NSUTF8StringEncoding];
                superNode.preNode = node;
                superNode.ivarName = @"Super Class";
                [nodeQueue addObject:superNode];
                superClass = [superClass superclass];
            }
        }
        
        unsigned int countOfIavrs = 0;
        // 关键方法，从class取出ivar列表
        Ivar *ivars = class_copyIvarList(class, &countOfIavrs);
        
        for (int i = 0; i < countOfIavrs; i++) {
            Ivar ivar = ivars[i];
            NSString *ivarClassNameStr = [self _classNameWithIvar:ivar];
            
            if (!ivarClassNameStr) {
                continue;
            }

//            NSLog(@"查找中---%s【%@】", ivar_getName(ivar), ivarClassNameStr);
            if ([ivarClassNameStr isEqualToString:target]) {
                NSLog(@"===========搜索到结果(搜索了%d次)============", searchCount);
                NSLog(@"Class Name:【%@】,Ivar Name:【%s】", ivarClassNameStr, ivar_getName(ivar));
                BFSSearchNode *currentNode = node;
                while (currentNode.preNode) {
                    NSLog(@"Class Name:【%@】,Ivar Name:【%@】", currentNode.className, currentNode.ivarName);
                    currentNode = currentNode.preNode;
                }
                NSLog(@"Root Class:%@", from);
            }
            
            Class ivarClass = objc_getClass(ivarClassNameStr.UTF8String);
            if (ivarClass) {
                BFSSearchNode *nextNode = [[BFSSearchNode alloc] init];
                nextNode.className = [NSString stringWithCString:class_getName(ivarClass) encoding:NSUTF8StringEncoding];
                nextNode.preNode = node;
                nextNode.ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
                [nodeQueue addObject:nextNode];
            }
        }
    }
}

/**
 通过Ivar获取Class名
 */
+ (NSString *)_classNameWithIvar:(Ivar)ivar {
    const char *classNameChar = ivar_getTypeEncoding(ivar);
    NSString *className = [NSString stringWithCString:classNameChar encoding:NSUTF8StringEncoding];
//    NSLog(@"【%@】%s", className, ivar_getName(ivar));
    
    // 过滤不是类的情况
    if ([self _ignore:className]) {
        return nil;
    }
    
    // 取出类名
    // 类：@"UIWebViewInternal"
    // 代理：@"<UIViewControllerTransitioningDelegate>"
    className = [className stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\"<>"]];
    return className;
}

/**
 过滤不是类的情况，参考
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 */
+ (BOOL)_ignore:(NSString *)typeEncoding {
    NSString *firstChar = [typeEncoding substringToIndex:1];
    if ([firstChar isEqualToString:@"["] ||
        [firstChar isEqualToString:@"{"] ||
        [firstChar isEqualToString:@"("] ||
        [firstChar isEqualToString:@"^"]) {
        return YES;
    }
    
    if ([self _isNumBits:typeEncoding]) {
        return YES;
    }
    
    NSSet *ignoreSet = [NSSet setWithObjects:@"c", @"i", @"s", @"l", @"q", @"C", @"I", @"S", @"L", @"Q", @"f", @"d", @"B", @"v", @"*", @"#", @"@", @"@?", @":", nil];
    if ([ignoreSet containsObject:typeEncoding]) {
        return YES;
    } else {
        return NO;
    }
}

/**
 A bit field of num bits
 type ecoding:bnum
 */
+ (BOOL)_isNumBits:(NSString *)typeEncoding {
    NSString *firstChar = [typeEncoding substringToIndex:1];
    
    if ([firstChar isEqualToString:@"b"]) {
        NSString *restStr = [typeEncoding substringFromIndex:1];
        NSUInteger length = restStr.length;
        const char *c = restStr.UTF8String;
        for (int i= 0 ; i < length; i++) {
            if (c[i] < '0' || c[i] > '9') {
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}

@end
