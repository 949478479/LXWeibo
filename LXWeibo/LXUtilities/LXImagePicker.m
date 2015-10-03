//
//  LXImagePicker.m
//  这到底是个什么鬼
//
//  Created by 从今以后 on 15/9/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXUtilities.h"
#import "LXImagePicker.h"

@interface LXImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, assign) BOOL isBlockMode;

@property (nonatomic, strong) LXImagePickCompletionHandler    completionHandler;
@property (nonatomic, strong) LXImagePickCancelHandler        cancelHandler;
@property (nonatomic, strong) LXSourceTypeNotAvailableHandler notAvailableHandler;

@end

@implementation LXImagePicker

#pragma mark - *** 公共方法 ***

- (void)showActionSheet
{
    NSAssert(self.delegate || self.completionHandler, @"若不使用 block 则需设置 delegate.");

    UIAlertControllerStyle style = LXDeviceIsPad() ?
        UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:style];

    UIAlertAction *photoAction =
        [UIAlertAction actionWithTitle:@"相册"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self p_presentImagePickerControllerWithSourceType:
                                    UIImagePickerControllerSourceTypePhotoLibrary];
                               }];

    UIAlertAction *cameraAction =
        [UIAlertAction actionWithTitle:@"相机"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self p_presentImagePickerControllerWithSourceType:
                                    UIImagePickerControllerSourceTypeCamera];
                               }];

    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"取消"
                                 style:UIAlertActionStyleCancel
                               handler:nil];

    [alertController addAction:photoAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancelAction];

    [LXTopViewController() presentViewController:alertController animated:YES completion:nil];
}

- (void)showActionSheetWithImagePickCompletionHandler:(LXImagePickCompletionHandler)completionHandler
                                        cancelHandler:(LXImagePickCancelHandler)cancelHandler
                        sourceTypeNotAvailableHandler:(LXSourceTypeNotAvailableHandler)notAvailableHandler
{
    self.isBlockMode = YES;

    self.completionHandler   = completionHandler;
    self.cancelHandler       = cancelHandler;
    self.notAvailableHandler = notAvailableHandler;

    [self showActionSheet];
}

- (BOOL)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    return [self p_presentImagePickerControllerWithSourceType:sourceType];
}

- (BOOL)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                                 completionHandler:(LXImagePickCompletionHandler)completionHandler
                                     cancelHandler:(LXImagePickCancelHandler)cancelHandler
{
    self.isBlockMode = YES;

    self.cancelHandler     = cancelHandler;
    self.completionHandler = completionHandler;

    return [self p_presentImagePickerControllerWithSourceType:sourceType];
}

#pragma mark - *** 私有方法 ***

#pragma mark - 辅助方法

- (BOOL)p_presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    NSAssert((self.delegate && !self.isBlockMode) || (self.completionHandler && self.isBlockMode),
             @"若不使用 block 则需设置 delegate.");

    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {

        if (self.isBlockMode) {

            if (self.notAvailableHandler) {
                self.notAvailableHandler();
            }

            self.cancelHandler       = nil;
            self.completionHandler   = nil;
            self.notAvailableHandler = nil;

        } else if ([self.delegate respondsToSelector:@selector(imagePickerSourceTypeNotAvailable:)]) {
            [self.delegate imagePickerSourceTypeNotAvailable:self];
        }

        return NO;
    }

    UIImagePickerController *ipc = [UIImagePickerController new];
    {
        ipc.delegate      = self;
        ipc.sourceType    = sourceType;
        ipc.allowsEditing = self.allowsEditing;
    }
    
    [LXTopViewController() presentViewController:ipc animated:YES completion:nil];

    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage   = info[UIImagePickerControllerEditedImage];

    if (self.isBlockMode) {

        self.completionHandler(originalImage, editedImage);
        
        self.cancelHandler       = nil;
        self.completionHandler   = nil;
        self.notAvailableHandler = nil;

        return;
    }

    [self.delegate imagePicker:self didFinishPickingOriginalImage:originalImage editedImage:editedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if (self.isBlockMode) {

        if (self.cancelHandler) {
            self.cancelHandler();
        }

        self.cancelHandler       = nil;
        self.completionHandler   = nil;
        self.notAvailableHandler = nil;

        return;
    }

    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}

@end