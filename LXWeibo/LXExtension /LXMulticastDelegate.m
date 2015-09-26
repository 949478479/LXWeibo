//
//  LXMulticastDelegate.m
//
//  Created by 从今以后 on 15/9/25.
//  Copyright © 2015年 apple. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXMulticastDelegate.h"

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

@interface LXMulticastDelegate ()

@property (nonatomic, strong) Protocol    *protocol;
@property (nonatomic, strong) NSHashTable *delegates;

@end

@implementation LXMulticastDelegate

#pragma mark - 初始化

- (instancetype)initWithProtocol:(Protocol *)protocol delegate:(id)delegate
{
    NSAssert(protocol, @"参数 protocol 为 nil.");
    NSAssert(!delegate || [delegate conformsToProtocol:protocol],
             @"delegate 未遵循协议 => <%s>", protocol_getName(protocol));

    _protocol  = protocol;
    _delegates = [NSHashTable weakObjectsHashTable];
    if (delegate) {
        [_delegates addObject:delegate];
    }

    return self;
}

#pragma mark - 添加/移除代理成员

- (void)addDelegate:(id)delegate
{
    NSAssert(delegate, @"参数 delegate 为 nil.");
    NSAssert([delegate conformsToProtocol:self.protocol],
             @"delegate 未遵循协议 => <%s>", protocol_getName(self.protocol));

    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate
{
    NSAssert(delegate, @"参数 delegate 为 nil.");

    [self.delegates removeObject:delegate];
}

- (void)removeAllDelegates
{
    [self.delegates removeAllObjects];
}

#pragma mark - 消息转发

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    // 先查找 required 协议方法.
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, sel, YES, YES);

    // 若未找到,进一步查找 option 协议方法.
    if (!desc.types) {
        desc = protocol_getMethodDescription(self.protocol, sel, NO, YES);
    }

    // 若找到,生成方法签名.
    if (desc.types) {
        return [NSMethodSignature signatureWithObjCTypes:desc.types];
    }

    /* 返回 nil 将直接导致如下异常.为了能显示类名我自己抛异常好了.
     *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
     reason: '*** -[NSProxy doesNotRecognizeSelector:objectAtIndex:] called!' */
    NSString *reason = [NSString stringWithFormat:@"*** -[%@ doesNotRecognizeSelector:%@] called!",
                        self.class, NSStringFromSelector(sel)];
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:reason
                                 userInfo:nil];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL sel = invocation.selector;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:sel]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

#pragma mark - 调试

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>\n%@", self.class, self, self.delegates.allObjects];
}

@end