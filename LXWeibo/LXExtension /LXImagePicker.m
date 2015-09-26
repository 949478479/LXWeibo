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

@property (nonatomic, strong) LXImagePickCompletionHandler completionHandler;
@property (nonatomic, strong) LXImagePickCancelHandler cancelHandler;

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
                                   [self presentImagePickerControllerWithSourceType:
                                    UIImagePickerControllerSourceTypePhotoLibrary];
                               }];

    UIAlertAction *cameraAction =
        [UIAlertAction actionWithTitle:@"相机"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self presentImagePickerControllerWithSourceType:
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
{
    NSAssert(completionHandler, @"参数 completionHandler 不能为 nil.");

    self.completionHandler = completionHandler;
    self.cancelHandler     = cancelHandler;

    [self showActionSheet];
}

#pragma mark - *** 私有方法 ***

#pragma mark - 辅助方法

- (void)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *ipc = [UIImagePickerController new];
    {
        ipc.delegate      = self;
        ipc.sourceType    = sourceType;
        ipc.allowsEditing = self.allowsEditing;
    }
    
    [LXTopViewController() presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage   = info[UIImagePickerControllerEditedImage];

    if (self.completionHandler)
    {
        self.completionHandler(originalImage, editedImage);
        
        self.completionHandler = nil;
        self.cancelHandler     = nil;
    }
    else if (self.delegate)
    {
        [self.delegate imagePicker:self
     didFinishPickingOriginalImage:originalImage
                       editedImage:editedImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if (self.cancelHandler)
    {
        self.cancelHandler();
    }
    else if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)])
    {
        [self.delegate imagePickerDidCancel:self];
    }

    self.completionHandler = nil;
    self.cancelHandler     = nil;
}

@end