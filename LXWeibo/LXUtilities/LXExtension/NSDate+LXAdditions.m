//
//  NSDate+LXAdditions.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSDate+LXAdditions.h"

@implementation NSDate (LXAdditions)

- (BOOL)lx_isThisMinute
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];

    NSAssert(timeInterval >= 0, @"测试时间晚于当前时间.");

    return timeInterval < 60;
}

- (BOOL)lx_isThisHour
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];

    NSAssert(timeInterval >= 0, @"测试时间晚于当前时间.");

    return timeInterval < 3600;
}

- (BOOL)lx_isYesterday
{
    return [[NSCalendar currentCalendar] isDateInYesterday:self];
}

- (BOOL)lx_isToday
{
    return [[NSCalendar currentCalendar] isDateInToday:self];
}

- (BOOL)lx_isTomorrow
{
    return [[NSCalendar currentCalendar] isDateInTomorrow:self];
}

- (BOOL)lx_isThisYear
{
    return [[NSCalendar currentCalendar] isDate:self
                                    equalToDate:[NSDate date]
                              toUnitGranularity:NSCalendarUnitYear];
}

- (BOOL)lx_isWeekend
{
    return [[NSCalendar currentCalendar] isDateInWeekend:self];
}

- (BOOL)lx_isSameDayAsDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] isDate:self inSameDayAsDate:date];
}

@end