//
//  LXUtilities.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXMacro.h"
@class AppDelegate;

///------------------------------------------------------------------------------------------------
/// @name 类扩展头文件
///------------------------------------------------------------------------------------------------

#import "NSDate+LXAdditions.h"
#import "UIView+LXAdditions.h"
#import "CALayer+LXAdditions.h"
#import "UIImage+LXAdditions.h"
#import "UIColor+LXAdditions.h"
#import "NSArray+LXAdditions.h"
#import "UIButton+LXAdditions.h"
#import "NSObject+LXAdditions.h"
#import "NSString+LXAdditions.h"
#import "UITextView+LXAdditions.h"
#import "UITextField+LXAdditions.h"
#import "UIStoryboard+LXAdditions.h"
#import "NSDictionary+LXAdditions.h"
#import "NSFileManager+LXAdditions.h"
#import "NSUserDefaults+LXAdditions.h"
#import "UIViewController+LXAdditions.h"
#import "NSAttributedString+LXAdditions.h"
#import "NSNotificationCenter+LXAdditions.h"

//#import "MBProgressHUD+LXAdditions.h"
//#import "LXImagePicker.h"
//#import "LXMulticastDelegate.h"

NS_ASSUME_NONNULL_BEGIN

///------------------------------------------------------------------------------------------------
/// @name 版本号
///------------------------------------------------------------------------------------------------

NSString * LXBundleVersionString();
NSString * LXBundleShortVersionString();

///------------------------------------------------------------------------------------------------
/// @name 沙盒路径
///------------------------------------------------------------------------------------------------

NSString * LXDocumentDirectory();
NSString * LXDocumentDirectoryByAppendingPathComponent(NSString *pathComponent);

NSString * LXLibraryDirectory();
NSString * LXLibraryDirectoryByAppendingPathComponent(NSString *pathComponent);

NSString * LXCachesDirectory();
NSString * LXCachesDirectoryByAppendingPathComponent(NSString *pathComponent);

///------------------------------------------------------------------------------------------------
/// @name 设备信息
///------------------------------------------------------------------------------------------------

BOOL LXDeviceIsPad();

///------------------------------------------------------------------------------------------------
/// @name AppDelegate
///------------------------------------------------------------------------------------------------

AppDelegate * LXAppDelegate();

///------------------------------------------------------------------------------------------------
/// @name 屏幕|窗口|控制器
///------------------------------------------------------------------------------------------------

CGSize LXScreenSize();
CGFloat LXScreenScale();

UIWindow * LXKeyWindow();
UIWindow * LXTopWindow();

UIViewController * LXTopViewController();
UIViewController * LXRootViewController();

///------------------------------------------------------------------------------------------------
/// @name GCD
///------------------------------------------------------------------------------------------------

dispatch_source_t LXGCDTimer(NSTimeInterval interval,
                             NSTimeInterval leeway,
                             dispatch_block_t handler,
                             _Nullable dispatch_block_t cancelHandler);

void LXGCDDelay(NSTimeInterval delayInSeconds, dispatch_block_t handler);

///------------------------------------------------------------------------------------------------
/// @name 方法交换
///------------------------------------------------------------------------------------------------

void LXMethodSwizzling(Class cls, SEL originalSelector, SEL swizzledSelector);

NS_ASSUME_NONNULL_END