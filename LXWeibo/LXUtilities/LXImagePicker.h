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

@protocol LXImagePickerDelegate <NSObject>

- (void)imagePicker:(LXImagePicker *)imagePicker
    didFinishPickingOriginalImage:(UIImage *)originalImage
        editedImage:(UIImage *)editedImage;

@optional
- (void)imagePickerDidCancel:(LXImagePicker *)imagePicker;

@end

@interface LXImagePicker : NSObject

@property (nonatomic, assign) BOOL allowsEditing;

@property (nullable, nonatomic, weak) id<LXImagePickerDelegate> delegate;

- (void)showActionSheet;

- (void)showActionSheetWithImagePickCompletionHandler:(LXImagePickCompletionHandler)completionHandler
                                        cancelHandler:(nullable LXImagePickCancelHandler)cancelHandler;

@end

NS_ASSUME_NONNULL_END