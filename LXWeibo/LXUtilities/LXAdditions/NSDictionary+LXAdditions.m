//
//  NSDictionary+LXAdditions.m
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSObject+LXAdditions.h"
#import "NSDictionary+LXAdditions.h"

@implementation NSDictionary (LXAdditions)

#pragma mark - 函数式便捷方法

- (NSArray *)lx_map:(id _Nullable (^)(id _Nonnull, id _Nonnull))map
{
    NSMutableArray *array = [NSMutableArray new];

    if (self.count == 0) {
        return array;
    }

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                              id _Nonnull obj,
                                              BOOL * _Nonnull stop) {
        id result = map(key, obj);
        if (result) {
            [array addObject:result];
        }
    }];
    return array; // 出于性能考虑就不 copy 了.
}

- (instancetype)lx_filter:(BOOL (^)(id _Nonnull, id _Nonnull))filter
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    if (self.count == 0) {
        return dict;
    }

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                              id _Nonnull obj,
                                              BOOL * _Nonnull stop) {
        if (filter(key, obj)) {
            dict[key] = obj;
        }
    }];

    return dict; // 出于性能考虑就不 copy 了.
}

- (id)lx_reduceWithInitial:(id)initial
                   combine:(id _Nullable (^)(id _Nullable, id _Nonnull, id _Nonnull))combine
{
    __block id result = initial;

    if (self.count == 0) {
        return result;
    }

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                              id _Nonnull obj,
                                              BOOL * _Nonnull stop) {
        result = combine(result, key, obj);
    }];
    return result;
}

#pragma mark - log 增强

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *description = [NSMutableString stringWithString:@"{\n"];

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableString *subDescription = [NSMutableString stringWithFormat:@"    %@ = %@;\n", key, obj];
        if ([obj isKindOfClass:[NSArray class]] ||
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj conformsToProtocol:@protocol(LXDescription)]) {
            [subDescription replaceOccurrencesOfString:@"\n"
                                            withString:@"\n    "
                                               options:(NSStringCompareOptions)0
                                                 range:(NSRange){0,subDescription.length - 1}];
        }
        [description appendString:subDescription];
    }];

    [description appendString:@"}"];

    return description;
}

@end