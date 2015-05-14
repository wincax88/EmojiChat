//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Genki Kondo on 9/18/12.
//  Copyright (c) 2012 Genki Kondo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "GKImagePicker.h"

@interface GKImagePicker ()
<
GKImageCropperDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate
>
{
    CGRect  showFromRect;
    UIView  *showInView;
}

@property(nonatomic, strong) UIPopoverController *popover;

- (void)presentImageCropperWithImage:(UIImage *)image;

@end

@implementation GKImagePicker 

@synthesize delegate = _delegate;
@synthesize cropper = _cropper;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cropper = [[GKImageCropper alloc] init];
        self.cropper.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View control

- (void)presentPicker:(CGRect)rect inView:(UIView*)view {

    // **********************************************
    // * Show action sheet that will allow image selection from camera or gallery
    // **********************************************
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    // actionSheet.alpha=0.90;
    actionSheet.tag = 1;
    actionSheet.delegate = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        showFromRect = rect;
        showInView = view;
        // In this case the device is an iPad.
        [actionSheet showFromRect:rect inView:view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)presentImageCropperWithImage:(UIImage *)image {    
    // **********************************************
    // * Show GKImageCropper
    // **********************************************
    self.cropper.image = image;
    [(UIViewController *)self.delegate presentViewController:[[UINavigationController alloc] initWithRootViewController:self.cropper] animated:YES completion:nil];
}

#pragma mark - Image picker methods
/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    [self showCameraImagePicker];
                    break;
                case 1:
                    [self showGalleryImagePicker];
                    break;
            }
            break;
        default:
            break;
    }
}
*/
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
{
    switch (actionSheet.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self showCameraImagePicker];
                    });
                }
                     break;
                case 1:
                {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self showGalleryImagePicker];
                    });
                }
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)showCameraImagePicker {
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Simulator" message:@"Camera not available." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
#elif TARGET_OS_IPHONE
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [(UIViewController *)self.delegate presentViewController:picker animated:YES completion:nil];
#endif
}

- (void)showGalleryImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.popover) {
            [self.popover dismissPopoverAnimated:NO];
            self.popover = nil;
        }
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.popover presentPopoverFromRect:showFromRect inView:showInView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [(UIViewController *)self.delegate presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self presentImageCropperWithImage:image];
    }];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [(UIViewController *)self.delegate dismissViewControllerAnimated:YES completion:^{
                [self presentImageCropperWithImage:image];
            }];
        }
        else {
            if (self.popover.isPopoverVisible) {
                [self.popover dismissPopoverAnimated:NO];
            }
            [self presentImageCropperWithImage:image];
        }
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentImageCropperWithImage:image];
        }];
    }
/*
    [picker dismissViewControllerAnimated:YES completion:^{
        // Extract image from the picker
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self presentImageCropperWithImage:image];
        }
    }];*/
}

#pragma mark - GKImageCropper delegate methods

- (void)imageCropperDidFinish:(GKImageCropper *)imageCropper withImage:(UIImage *)image {
    [self.delegate imagePickerDidFinish:self withImage:image];
}

@end
