//
//  NSObject+LXExtension.m
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "NSObject+LXExtension.h"
#import "NSObject+DLIntrospection.h"

@implementation NSObject (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印变量

+ (void)lx_printIvars
{
    NSLog(@"%@", [self dl_instanceVariables]);
}

- (void)lx_printIvars
{
    [[self class] lx_printIvars];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印属性

+ (void)lx_printProperties
{
    NSLog(@"%@", [self dl_properties]);
}

- (void)lx_printProperties
{
    [[self class] lx_printProperties];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印方法

+ (void)lx_printMethods
{
    NSLog(@"%@", [self dl_classMethods]);
}

- (void)lx_printMethods
{
    NSLog(@"%@", [[self class] dl_instanceMethods]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 获取属性数组

+ (NSArray<NSString *> *)lx_properties
{
    NSMutableArray *propertyArray = [NSMutableArray new];
    {
        uint outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [propertyArray addObject:(NSString *)[NSString stringWithUTF8String:property_getName(properties[i])]];
        }
        free(properties);
    }
    return propertyArray;
}

- (NSArray<NSString *> *)lx_properties
{
    return [[self class] lx_properties];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 获取实例变量数组

+ (NSArray<NSString *> *)lx_variables
{
    NSMutableArray *ivarArray = [NSMutableArray new];
    {
        uint outCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [ivarArray addObject:(NSString *)[NSString stringWithUTF8String:ivar_getName(ivars[i])]];
        }
        free(ivars);
    }
    return ivarArray;
}

- (NSArray<NSString *> *)lx_variables
{
    return [[self class] lx_variables];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 调试

- (NSString *)lx_description
{
    NSMutableDictionary *varInfo = [NSMutableDictionary new];
    for (NSString *varName in self.lx_variables) {
        varInfo[varName] = [self valueForKey:varName] ?: [NSNull null];
    }
    return [NSString stringWithFormat:@"<%@: %p>\n%@", self.class, self, varInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 关联对象

- (void)lx_setValue:(id)value forKey:(NSString *)key
{
    NSAssert(key.length, @"参数 key 为空字符串或 nil.");

    objc_setAssociatedObject(self, NSSelectorFromString(key), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)lx_valueForKey:(NSString *)key
{
    NSAssert(key.length, @"参数 key 为空字符串或 nil.");
    
    return objc_getAssociatedObject(self, NSSelectorFromString(key));
}

@end