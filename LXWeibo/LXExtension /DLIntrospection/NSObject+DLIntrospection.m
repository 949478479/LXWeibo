//
//  NSObject+DLIntrospection.m
//  DLIntrospection
//
//  Created by Denis Lebedev on 12/27/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//

@import ObjectiveC.runtime;
#import "NSObject+DLIntrospection.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSString (DLIntrospection)

+ (NSString *)dl_decodeType:(const char *)cString
{
    if (!strcmp(cString, @encode(id)))           return @"id";
    if (!strcmp(cString, @encode(void)))         return @"void";
    if (!strcmp(cString, @encode(float)))        return @"float";
    if (!strcmp(cString, @encode(int)))          return @"int";
    if (!strcmp(cString, @encode(BOOL)))         return @"BOOL";
    if (!strcmp(cString, @encode(char *)))       return @"char *";
    if (!strcmp(cString, @encode(double)))       return @"double";
    if (!strcmp(cString, @encode(Class)))        return @"class";
    if (!strcmp(cString, @encode(SEL)))          return @"SEL";
    if (!strcmp(cString, @encode(unsigned int))) return @"unsigned int";

// @TODO: do handle bitmasks
    NSString *result = [NSString stringWithUTF8String:cString];
    if ([[result substringToIndex:1] isEqualToString:@"@"] &&
        [result rangeOfString:@"?"].location == NSNotFound) {

        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    }
    else if ([[result substringToIndex:1] isEqualToString:@"^"]) {
        result = [NSString stringWithFormat:@"%@ *", [NSString dl_decodeType:[result substringFromIndex:1].UTF8String]];
    }

    return result;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSObject (DLIntrospection)

#pragma mark - 全部类&继承树

+ (NSArray<NSString *> *)dl_classes
{
    NSMutableArray *result = [NSMutableArray array];
    {
        uint classesCount;
        Class *classes = objc_copyClassList(&classesCount);
        for (uint i = 0 ; i < classesCount; i++) {
            [result addObject:NSStringFromClass(classes[i])];
        }
    }

    return [result sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSString *)dl_parentClassHierarchy
{
    NSMutableString *result = [NSMutableString string];
    dl_getSuper([self class], result);
    return [result copy];
}

static void dl_getSuper(Class class, NSMutableString *result)
{
    [result appendFormat:@" -> %@", NSStringFromClass(class)];

    if ([class superclass]) {
        dl_getSuper([class superclass], result);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 属性&实例变量

+ (NSArray<NSString *> *)dl_properties
{
    NSMutableArray *result = [NSMutableArray array];
    {
        uint outCount;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (uint i = 0; i < outCount; i++) {
            [result addObject:[self dl_formattedPropery:properties[i]]];
        }
        free(properties);
    }

    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)dl_instanceVariables
{
    NSMutableArray *result = [NSMutableArray array];
    {
        uint outCount;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (uint i = 0; i < outCount; i++) {
            NSString *type = [NSString dl_decodeType:ivar_getTypeEncoding(ivars[i])];
            NSString *name = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
            NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
            [result addObject:ivarDescription];
        }
        free(ivars);
    }

    return result.count ? [result copy] : nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 方法

+ (NSArray<NSString *> *)dl_classMethods
{
    return [self dl_methodsForClass:object_getClass([self class]) typeFormat:@"+"];
}

+ (NSArray<NSString *> *)dl_instanceMethods
{
    return [self dl_methodsForClass:[self class] typeFormat:@"-"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 协议

+ (NSArray<NSString *> *)dl_protocols
{
    NSMutableArray *result = [NSMutableArray array];
    {
        uint outCount;
        Protocol *__unsafe_unretained *protocols = class_copyProtocolList([self class], &outCount);
        for (uint i = 0; i < outCount; i++) {

            uint adoptedCount;
            Protocol *__unsafe_unretained *adotedProtocols = protocol_copyProtocolList(protocols[i], &adoptedCount);

            NSMutableArray *adoptedProtocolNames = [NSMutableArray array];
            {
                for (uint idx = 0; idx < adoptedCount; idx++) {
                    [adoptedProtocolNames addObject:(NSString *)[NSString stringWithUTF8String:protocol_getName(adotedProtocols[idx])]];
                }
            }

            NSString *protocolDescription = [NSString stringWithUTF8String:protocol_getName(protocols[i])];
            {
                if (adoptedProtocolNames.count) {
                    protocolDescription = [NSString stringWithFormat:@"%@ <%@>",
                                           protocolDescription,
                                           [adoptedProtocolNames componentsJoinedByString:@", "]];
                }
            }
            
            [result addObject:protocolDescription];

            free(adotedProtocols);
        }
        
        free(protocols);
    }

    return result.count ? [result copy] : nil;
}

+ (NSDictionary<NSString *,NSString *> *)dl_descriptionForProtocol:(Protocol *)proto
{
    Class cls = [self class];

    NSArray *requiredMethods = nil;
    {
        NSArray *classMethods    = [cls dl_formattedMethodsForProtocol:proto required:YES instance:NO];
        NSArray *instanceMethods = [cls dl_formattedMethodsForProtocol:proto required:YES instance:YES];

        requiredMethods = [classMethods arrayByAddingObjectsFromArray:instanceMethods];
    }

    NSArray *optionalMethods = nil;
    {
        NSArray *classMethods    = [cls dl_formattedMethodsForProtocol:proto required:NO instance:NO];
        NSArray *instanceMethods = [cls dl_formattedMethodsForProtocol:proto required:NO instance:YES];

        optionalMethods = [classMethods arrayByAddingObjectsFromArray:instanceMethods];
    }

    NSMutableArray *propertyDescriptions = [NSMutableArray array];
    {
        uint propertiesCount;
        objc_property_t *properties = protocol_copyPropertyList(proto, &propertiesCount);
        for (uint i = 0; i < propertiesCount; i++) {
            [propertyDescriptions addObject:[self dl_formattedPropery:properties[i]]];
        }
        free(properties);
    }

    NSMutableDictionary *methodsAndProperties = [NSMutableDictionary dictionary];
    {
        if (requiredMethods.count) {
            methodsAndProperties[@"@required"] = requiredMethods;
        }

        if (optionalMethods.count) {
            methodsAndProperties[@"@optional"] = optionalMethods;
        }

        if (propertyDescriptions.count) {
            methodsAndProperties[@"@properties"] = [propertyDescriptions copy];
        }
    }

    return methodsAndProperties.count ? [methodsAndProperties copy ] : nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Private

+ (NSArray<NSString *> *)dl_methodsForClass:(Class)class typeFormat:(NSString *)type
{
    NSMutableArray *result = [NSMutableArray array];
    {
        uint outCount;
        Method *methods = class_copyMethodList(class, &outCount);
        for (uint i = 0; i < outCount; i++) {
            NSString *methodDescription = [NSString stringWithFormat:@"%@ (%@)%@",
                                           type,
                                           [NSString dl_decodeType:method_copyReturnType(methods[i])],
                                           NSStringFromSelector(method_getName(methods[i]))];

            NSMutableArray *selParts = [[methodDescription componentsSeparatedByString:@":"] mutableCopy];

            uint offset = 2;//1-st arg is object (@), 2-nd is SEL (:)
            uint args   = method_getNumberOfArguments(methods[i]);

            for (uint idx = offset; idx < args; idx++) {
                NSString *returnType = [NSString dl_decodeType:method_copyArgumentType(methods[i], idx)];
                selParts[idx - offset] = [NSString stringWithFormat:@"%@:(%@)arg%d",
                                          selParts[idx - offset],
                                          returnType,
                                          idx - 2];
            }

            [result addObject:[selParts componentsJoinedByString:@" "]];
        }
        
        free(methods);
    }

    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)dl_formattedMethodsForProtocol:(Protocol *)proto
                                required:(BOOL)required
                                instance:(BOOL)instance
{
    NSMutableArray *methodsDescription = [NSMutableArray array];
    {
        uint methodCount;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(proto, required, instance, &methodCount);
        for (uint i = 0; i < methodCount; i++) {
            [methodsDescription addObject:[NSString stringWithFormat:@"%@ (%@)%@",
                                           instance ? @"-" : @"+",
                                           @"void",
                                           NSStringFromSelector(methods[i].name)]];
        }
        free(methods);
    }

    return [methodsDescription copy];
}

+ (NSString *)dl_formattedPropery:(objc_property_t)prop
{
    NSMutableDictionary<NSString *, NSString *> *attributes = [NSMutableDictionary dictionary];
    {
        uint attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(prop, &attrCount);
        for (uint idx = 0; idx < attrCount; idx++) {

            NSString *name  = [NSString stringWithCString:attrs[idx].name  encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[idx].value encoding:NSUTF8StringEncoding];

            attributes[name] = value;
        }
        free(attrs);
    }

    NSMutableArray<NSString *> *attrsArray = [NSMutableArray array];
    {
        [attrsArray addObject:attributes[@"N"] ? @"nonatomic" : @"atomic"];

        if (attributes[@"&"]) {
            [attrsArray addObject:@"strong"];
        }
        else if (attributes[@"C"]) {
            [attrsArray addObject:@"copy"];
        }
        else if (attributes[@"W"]) {
            [attrsArray addObject:@"weak"];
        }
        else {
            [attrsArray addObject:@"assign"];
        }

        if (attributes[@"R"]) {
            [attrsArray addObject:@"readonly"];
        }

        if (attributes[@"G"]) {
            [attrsArray addObject:[NSString stringWithFormat:@"getter=%@", attributes[@"G"]]];
        }

        if (attributes[@"S"]) {
            [attrsArray addObject:[NSString stringWithFormat:@"setter=%@", attributes[@"G"]]];
        }
    }

    NSMutableString *property = [NSMutableString stringWithFormat:@"@property "];
    {
        [property appendFormat: @"(%@) %@ %@",
         [attrsArray componentsJoinedByString:@", "],
         [NSString dl_decodeType:attributes[@"T"].UTF8String],
         [NSString stringWithUTF8String:property_getName(prop)]];
    }

    return [property copy];
}

@end