//
//  NSObject+DLIntrospection.h
//  DLIntrospection
//
//  Created by Denis Lebedev on 12/27/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DLIntrospection)

+ (NSArray<NSString *> *)dl_classes;
+ (NSString *)dl_parentClassHierarchy;

+ (nullable NSArray<NSString *> *)dl_properties;
+ (nullable NSArray<NSString *> *)dl_instanceVariables;

+ (nullable NSArray<NSString *> *)dl_classMethods;
+ (nullable NSArray<NSString *> *)dl_instanceMethods;

+ (nullable NSArray<NSString *> *)dl_protocols;
+ (nullable NSDictionary<NSString *, NSString *> *)dl_descriptionForProtocol:(Protocol *)proto;

@end

NS_ASSUME_NONNULL_END