//
//  NSArray+LXAdditions.m
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSArray+LXAdditions.h"
#import "NSObject+LXAdditions.h"

@implementation NSArray (LXAdditions)

#pragma mark - 常用方法

- (BOOL)lx_isEmpty
{
    return self.count == 0;
}

+ (instancetype)lx_arrayWithResourcePath:(NSString *)path
{
    NSAssert(path.length, @"参数 path 为空字符串或 nil.");

    return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:nil]];
}

#pragma mark - 函数式便捷方法

- (instancetype)lx_map:(id _Nullable (^)(id _Nonnull))map
{
    if (self.count == 0) {
        return self;
    }

    NSMutableArray *array = [NSMutableArray new];
    for (id obj in self) {
        id result = map(obj);
        if (result) {
            [array addObject:result];
        }
    }
    return array; // 出于性能考虑就不 copy 了.
}

- (instancetype)lx_filter:(BOOL (^)(id _Nonnull))filter
{
    if (self.count == 0) {
        return self;
    }

    NSMutableArray *array = [NSMutableArray new];
    for (id obj in self) {
        if (filter(obj)) {
            [array addObject:obj];
        }
    }
    return array; // 出于性能考虑就不 copy 了.
}

- (id)lx_reduceWithInitial:(id)initial combine:(id _Nullable (^)(id _Nullable, id _Nonnull))combine
{
    id result = initial;

    if (self.count == 0) {
        return result;
    }

    for (id item in self) {
        result = combine(result, item);
    }
    return result;
}

#pragma mark - log 增强

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *description = [NSMutableString stringWithString:@"(\n"];

    for (id obj in self) {
        NSMutableString *subDescription = [NSMutableString stringWithFormat:@"    %@,\n", obj];
        if ([obj isKindOfClass:[NSArray class]] ||
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj conformsToProtocol:@protocol(LXDescription)]) {
            [subDescription replaceOccurrencesOfString:@"\n"
                                            withString:@"\n    "
                                               options:(NSStringCompareOptions)0
                                                 range:(NSRange){0,subDescription.length - 1}];
        }
        [description appendString:subDescription];
    }

    [description appendString:@")"];

    return description;
}

@end