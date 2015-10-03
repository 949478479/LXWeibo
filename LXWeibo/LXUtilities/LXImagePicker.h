//
//  LXImagePicker.h
//
//  Created by 从今以后 on 15/9/26.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;
@class LXImagePicker;

NS_ASSUME_NONNULL_BEGIN

typedef void (^LXImagePickCompletionHandler)(UIImage *originalImage, UIImage * _Nullable editedImage);
typedef void (^LXImagePickCancelHandler)(void);
typedef void (^LXSourceTypeNotAvailableHandler)(void);

@protocol LXImagePickerDelegate <NSObject>

@required
- (void)imagePicker:(LXImagePicker *)imagePicker
    didFinishPickingOriginalImage:(UIImage *)originalImage
        editedImage:(UIImage *)editedImage;

@optional
- (void)imagePickerDidCancel:(LXImagePicker *)imagePicker;
- (void)imagePickerSourceTypeNotAvailable:(LXImagePicker *)imagePicker;

@end

@interface LXImagePicker : NSObject

@property (nonatomic, assign) BOOL allowsEditing;

@property (nullable, nonatomic, weak) id<LXImagePickerDelegate> delegate;

///------------------------------------------------------------------------------------------------
/// @name 弹出 ActionSheet
///------------------------------------------------------------------------------------------------

/**
 *  弹出选择相册或相机的 @c ActionSheet. 必须设置代理.
 */
- (void)showActionSheet;

/**
 *  弹出选择相册或相机的 @c ActionSheet. 不用设置代理.
 *
 *  @param completionHandler   选中照片后的回调 @c block.
 *  @param cancelHandler       取消后的回调 @c block.
 *  @param notAvailableHandler 对应来源不可用的回调 @c block.
 */
- (void)showActionSheetWithImagePickCompletionHandler:(LXImagePickCompletionHandler)completionHandler
                                        cancelHandler:(nullable LXImagePickCancelHandler)cancelHandler
                        sourceTypeNotAvailableHandler:(nullable LXSourceTypeNotAvailableHandler)notAvailableHandler;

///------------------------------------------------------------------------------------------------
/// @name 直接打开 UIImagePickerController
///------------------------------------------------------------------------------------------------

/**
 *  直接打开 @c UIImagePickerController.
 *
 *  @param sourceType 来源.
 *
 *  @return 若来源可用则弹出 @c UIImagePickerController 并返回 @c YES, 否则直接返回 @c NO.
 */
- (BOOL)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType;

/**
 *  直接打开 @c UIImagePickerController.
 *
 *  @param sourceType        来源.
 *  @param completionHandler 选中照片后的回调 @c block.
 *  @param cancelHandler     取消后的回调 @c block.
 *
 *  @return 若来源可用则弹出 @c UIImagePickerController 并返回 @c YES, 否则直接返回 @c NO.
 */
- (BOOL)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                                 completionHandler:(LXImagePickCompletionHandler)completionHandler
                                     cancelHandler:(nullable LXImagePickCancelHandler)cancelHandler;
@end

NS_ASSUME_NONNULL_END