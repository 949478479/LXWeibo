//
//  LXStatus.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"

@implementation LXStatus

@synthesize source     = _source;
@synthesize created_at = _created_at;

+ (NSDictionary *)objectClassInArray
{
    return @{ @"pic_urls" : [LXPhoto class] };
}

#pragma mark - 微博来源处理

- (void)setSource:(NSString * _Nonnull)source
{
    // <a href=\"http://app.weibo.com/t/feed/1tqBja\" rel=\"nofollow\">360安全浏览器</a>
    NSRange range = [source rangeOfString:@"(?<=>).+(?=<)" options:NSRegularExpressionSearch];

    // 发现个别时候来源为 @"" .
    if (range.location != NSNotFound) {
        _source = [NSString stringWithFormat:@"来自 %@", [source substringWithRange:range]];
    } else {
        _source = source;
    }
}

#pragma mark - 发表时间格式化处理

static inline NSDateFormatter * LXDateFromStringFormatter()
{
    static NSDateFormatter *sDateFromStringFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFromStringFormatter = [NSDateFormatter new];
        sDateFromStringFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        sDateFromStringFormatter.dateFormat = @"E MMM dd HH:mm:ss Z y"; // @"Tue Sep 30 17:06:25 +0800 2014"
    });
    return sDateFromStringFormatter;
}

static inline NSDateFormatter * LXNoThisYearFormatterFormatter()
{
    static NSDateFormatter *sNoThisYearFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNoThisYearFormatter = [NSDateFormatter new];
        sNoThisYearFormatter.dateFormat = @"y-MM-dd HH:mm";
    });
    return sNoThisYearFormatter;
}

static inline NSDateFormatter * LXYesterdayFormatter()
{
    static NSDateFormatter *sYesterdayFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sYesterdayFormatter = [NSDateFormatter new];
        sYesterdayFormatter.dateFormat = @"昨天 HH:mm";
    });
    return sYesterdayFormatter;
}

static inline NSDateFormatter * LXOtherDayInThisYearFormatter()
{
    static NSDateFormatter *sOtherDayInThisYearFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sOtherDayInThisYearFormatter = [NSDateFormatter new];
        sOtherDayInThisYearFormatter.dateFormat = @"MM-dd HH:mm";
    });
    return sOtherDayInThisYearFormatter;
}

- (NSString *)created_at
{
    NSDate *now = [NSDate date];
    NSDate *created_at = [LXDateFromStringFormatter() dateFromString:_created_at];

    BOOL isThisYear = [LXDateFromStringFormatter().calendar isDate:now
                                                       equalToDate:created_at
                                                 toUnitGranularity:NSCalendarUnitYear];
    if (isThisYear) { // 今年.

        BOOL isToday = [LXDateFromStringFormatter().calendar isDateInToday:created_at];

        if (isToday) { // 今天.

            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

            NSDateComponents *components = [LXDateFromStringFormatter().calendar components:unit
                                                                                   fromDate:created_at
                                                                                     toDate:now
                                                                                    options:0];
            if (components.hour >= 1) { // 1 小时前.
                return [NSString stringWithFormat:@"%ld小时前", (long)components.hour];
            } else if (components.minute >= 1) { // 1~59分钟
                return [NSString stringWithFormat:@"%ld分钟前", (long)components.minute];
            } else {
                return @"刚刚";
            }

        } else { // 非今天.

            BOOL isYesterday = [LXDateFromStringFormatter().calendar isDateInYesterday:created_at];

            if (isYesterday) { // 昨天. 格式类似: 昨天 23:39
                return [LXYesterdayFormatter() stringFromDate:created_at];
            } else { // 今年的其他日期. 格式类似: 10-29 23:39
                return [LXOtherDayInThisYearFormatter() stringFromDate:created_at];
            }
        }

    } else { // 非今年. 格式类似: 2012-04-01 19:17
        return [LXNoThisYearFormatterFormatter() stringFromDate:created_at];
    }
}

@end