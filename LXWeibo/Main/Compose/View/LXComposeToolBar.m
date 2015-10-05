//
//  LXComposeToolBar.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/3.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "XXNibBridge.h"
#import "LXComposeToolBar.h"

@interface LXComposeToolBar () <XXNibBridge>

@property (nonatomic, weak) IBOutlet UIButton *keyboardButton;

@end

@implementation LXComposeToolBar

#pragma mark - Setter

- (void)setShowKeyboardButton:(BOOL)showKeyboardButton
{
    UIImage *normalImage = nil, *highlightedImage = nil;
    if (showKeyboardButton) {
        normalImage = [UIImage imageNamed:@"compose_keyboardbutton_background"];
        highlightedImage = [UIImage imageNamed:@"compose_keyboardbutton_background_highlighted"];
    } else {
        normalImage = [UIImage imageNamed:@"compose_emoticonbutton_background"];
        highlightedImage = [UIImage imageNamed:@"compose_emoticonbutton_background_highlighted"];
    }
    self.keyboardButton.lx_normalImage = normalImage;
    self.keyboardButton.lx_highlightedImage = highlightedImage;

    _showKeyboardButton = showKeyboardButton;
}

#pragma mark - IBAction

- (IBAction)toolBarButtonDidTap:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(composeToolBar:didTapButtonWithType:)]) {
        [self.delegate composeToolBar:self didTapButtonWithType:sender.tag];
    }
}

@end