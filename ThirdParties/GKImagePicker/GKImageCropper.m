//
//  GKImageCropper.m
//  GKImageEditor
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

#import "GKImageCropper.h"
#import "UIImage+Resize.h"
#import "UIImage+Rotate.h"
#import "UIImage+FixOrientation.h"
#import "CommonDefine.h"

@interface GKImageCropper () <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    UIImageView *imageView;
    CGPoint     contentOffset;
}
@end

@implementation GKImageCropper

@synthesize delegate = _delegate;
@synthesize image = _image;
@synthesize cropSize = _cropSize;
@synthesize rescaleImage = _rescaleImage;
@synthesize rescaleFactor = _rescaleFactor;
@synthesize dismissAnimated = _dismissAnimated;
@synthesize overlayColor = _overlayColor;
@synthesize innerBorderColor = _innerBorderColor;

-(id)initWithImage:(UIImage*)theImage withCropSize:(CGSize)theSize willRescaleImage:(BOOL)willRescaleImage withRescaleFactor:(double)theFactor willDismissAnimated:(BOOL)willDismissAnimated {
    self = [super init];
    if(self) {
        self.image = theImage;
        // **********************************************
        // * Rotate image to proper orientation
        // **********************************************
        if (self.image.imageOrientation == UIImageOrientationRight) {
            self.image = [UIImage imageWithCGImage:[self.image CGImage]
                                        scale:1.0
                                  orientation: UIImageOrientationUp];
            self.image = [self.image imageRotatedByDegrees:90.0];
        } else if (self.image.imageOrientation == UIImageOrientationLeft) {
            self.image = [UIImage imageWithCGImage:[self.image CGImage]
                                        scale:1.0
                                  orientation: UIImageOrientationUp];
            self.image = [self.image imageRotatedByDegrees:-90.0];
        } else if (self.image.imageOrientation == UIImageOrientationDown) {
            self.image = [UIImage imageWithCGImage:[self.image CGImage]
                                        scale:1.0
                                  orientation: UIImageOrientationUp];
            self.image = [self.image imageRotatedByDegrees:180.0];
        }
        self.cropSize = theSize;
        self.rescaleImage = willRescaleImage;
        self.rescaleFactor = theFactor;
        self.dismissAnimated = willDismissAnimated;
    }
    return self;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // **********************************************
        // * Set default parameters
        // **********************************************
        self.image = [[UIImage alloc] init];
        self.cropSize = CGSizeMake(320.0,320.0);
        self.rescaleImage = YES;
        self.rescaleFactor = 1.0;
        self.dismissAnimated = YES;
        self.overlayColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7];
        self.innerBorderColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.7];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // **********************************************
    // * Set background color
    // **********************************************
    self.view.backgroundColor = [UIColor blackColor];
    
    // **********************************************
    // * Configure navigation item
    // **********************************************
    self.navigationController.navigationBarHidden = YES;
    /*
    self.navigationItem.title = @"Crop Image";
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(handleDoneButton)];
    [self.navigationItem setRightBarButtonItem:okButton animated:NO];*/
    
    // **********************************************
    // * Determine scroll zoom level
    // **********************************************
    double navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGRect rect = self.view.bounds;
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        if (self.view.frame.size.width < self.view.frame.size.height) {
            rect.size.width = self.view.frame.size.height;
            rect.size.height = self.view.frame.size.width;
        }
    }
    if (IS_IPAD && !IS_IOS8) {
        if (self.view.frame.size.width < self.view.frame.size.height) {
            rect.size.width = self.view.frame.size.height;
            rect.size.height = self.view.frame.size.width;
        }
    }
    
    double frameWidth = rect.size.width;
    double frameHeight = rect.size.height-navBarHeight;
    CGFloat imageWidth = CGImageGetWidth(self.image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(self.image.CGImage);
    float scaleX = self.cropSize.width / imageWidth;
    float scaleY = self.cropSize.height / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    
    // **********************************************
    // * Create scroll view
    // **********************************************
    CGRect frame = CGRectMake(0, 0, rect.size.width,rect.size.height);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

    scrollView.bounds = CGRectMake(0, 0,imageWidth, imageHeight);
    scrollView.frame = CGRectMake(0, 0, frameWidth, frameHeight);
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = self.image.size;
    scrollView.pagingEnabled = NO;
    scrollView.directionalLockEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    //Limit zoom
    scrollView.maximumZoomScale = scaleScroll*10.;
    scrollView.minimumZoomScale = scaleScroll;
    [self.view addSubview:scrollView];
    
    // **********************************************
    // * Create scroll view
    // **********************************************
    imageView = [[UIImageView alloc] initWithImage:self.image];
    [scrollView addSubview:imageView];
    
    [UIColor colorWithRed:0/255. green:140/255. blue:190/255. alpha:1];
    // **********************************************
    // * Create top shaded overlay
    // **********************************************
    UIImageView *overlayTop = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., frameWidth, frameHeight/2.-self.cropSize.height/2.)];
    overlayTop.backgroundColor = self.overlayColor;
    [self.view addSubview:overlayTop];
    
    // **********************************************
    // * Create bottom shaded overlay
    // **********************************************
    UIImageView *overlayBottom = [[UIImageView alloc] initWithFrame:CGRectMake(0., frameHeight/2.+self.cropSize.height/2., frameWidth, frameHeight/2.-self.cropSize.height/2.)];
    overlayBottom.backgroundColor = self.overlayColor;
    [self.view addSubview:overlayBottom];
    
    // **********************************************
    // * Create left shaded overlay
    // **********************************************
    UIImageView *overlayLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0., frameHeight/2.-self.cropSize.height/2., frameWidth/2.-self.cropSize.width/2., self.cropSize.height)];
    overlayLeft.backgroundColor = self.overlayColor;
    [self.view addSubview:overlayLeft];
    
    // **********************************************
    // * Create right shaded overlay
    // **********************************************
    UIImageView *overlayRight = [[UIImageView alloc] initWithFrame:CGRectMake(frameWidth/2.+self.cropSize.width/2., frameHeight/2.-self.cropSize.height/2., frameWidth/2.-self.cropSize.width/2., self.cropSize.height)];
    overlayRight.backgroundColor = self.overlayColor;
    [self.view addSubview:overlayRight];
    
    // **********************************************
    // * Create inner border overlay
    // **********************************************
    UIImageView *overlayInnerBorder = [[UIImageView alloc] initWithFrame:CGRectMake(frameWidth/2.-self.cropSize.width/2., frameHeight/2.-self.cropSize.height/2., self.cropSize.width, self.cropSize.height)];
    overlayInnerBorder.backgroundColor = [UIColor clearColor];
    overlayInnerBorder.layer.masksToBounds = YES;
    overlayInnerBorder.layer.borderColor = self.innerBorderColor.CGColor;
    overlayInnerBorder.layer.borderWidth = 1;
    [self.view addSubview:overlayInnerBorder];
    
    // **********************************************
    // * Set scroll view inset so that corners of images can be accessed
    // **********************************************
    scrollView.contentInset = UIEdgeInsetsMake(overlayTop.frame.size.height, overlayLeft.frame.size.width, overlayBottom.frame.size.height, overlayRight.frame.size.width);
    
    // **********************************************
    // * Add gesture recognizer for single tap to display image rotation menu
    // **********************************************
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:singleTap];
    
    // **********************************************
    // * Set initial zoom of scroll view
    // **********************************************
    [scrollView setZoomScale:scaleScroll animated:NO];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(handleCancelButton)];
    cancelButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"使用照片"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(handleDoneButton)];
    confirmButton.tintColor = [UIColor whiteColor];
    self.toolbarItems = @[cancelButton, flexibleSpace, confirmButton];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;

    CGRect imageFrame = imageView.frame;
    contentOffset.x = (-overlayInnerBorder.frame.size.width+imageFrame.size.width)/2.-overlayInnerBorder.frame.origin.x;
    contentOffset.y = (-overlayInnerBorder.frame.size.height+imageFrame.size.height)/2.-overlayInnerBorder.frame.origin.y;
    scrollView.contentOffset = contentOffset;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Release any retained subviews of the main view.
    [scrollView setContentOffset:contentOffset animated:YES] ;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Helper methods

UIImage* imageFromView(UIImage* srcImage, CGRect* rect) {
    UIImage *fixOrientation = [srcImage fixOrientation];
    CGImageRef cr = CGImageCreateWithImageInRect(fixOrientation.CGImage, *rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}

#pragma mark - User interaction handle methods
-(void)handleCancelButton {
    [self dismissViewControllerAnimated:self.dismissAnimated completion:^{
//        [self.delegate imageCropperDidFinish:self withImage:self.image];
    }];
}

-(void)handleDoneButton {
    // **********************************************
    // * Define CGRect to crop
    // **********************************************
    CGRect rect = self.view.bounds;
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        if (self.view.frame.size.width < self.view.frame.size.height) {
            rect.size.width = self.view.frame.size.height;
            rect.size.height = self.view.frame.size.width;
        }
    }
    if (IS_IPAD && !IS_IOS8) {
        if (self.view.frame.size.width < self.view.frame.size.height) {
            rect.size.width = self.view.frame.size.height;
            rect.size.height = self.view.frame.size.width;
        }
    }
    double cropAreaHorizontalOffset = rect.size.width/2.-self.cropSize.width/2.;
    double cropAreaVerticalOffset = rect.size.height/2.-self.cropSize.height/2.;
    CGRect cropRect;
    float scale = 1.0f/scrollView.zoomScale;
    cropRect.origin.x = (scrollView.contentOffset.x+cropAreaHorizontalOffset) * scale;
    cropRect.origin.y = (scrollView.contentOffset.y+cropAreaVerticalOffset) * scale;
    cropRect.size.width = self.cropSize.width * scale;
    cropRect.size.height = self.cropSize.height * scale;

    // **********************************************
    // * Crop image
    // **********************************************
    self.image = imageFromView(self.image, &cropRect);
    
    // **********************************************
    // * Resize image if willRescaleImage == YES
    // **********************************************
    if (self.rescaleImage) {
        self.image = [self.image resizedImage:CGSizeMake(self.cropSize.width*self.rescaleFactor,self.cropSize.height*self.rescaleFactor) interpolationQuality:kCGInterpolationDefault];
    }
    
    [self dismissViewControllerAnimated:self.dismissAnimated completion:^{
        [self.delegate imageCropperDidFinish:self withImage:self.image];
    }];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    return;
    // **********************************************
    // * Single tap shows rotation menu
    // **********************************************
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Rotate Clockwise", @"Rotate Counterclockwise", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.alpha=0.90;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

#pragma mark - Action sheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            // Rotate clockwise
            [self rotateImageByDegrees:90.0];
        } else if (buttonIndex == 1) {
            // Rotate counterclockwise
            [self rotateImageByDegrees:-90.0];
        }
    }
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark - Image rotation

- (void)rotateImageByDegrees:(CGFloat)degrees {
    double tempZoomScale = scrollView.zoomScale;
    self.image = [self.image imageRotatedByDegrees:degrees];
    imageView = [[UIImageView alloc] initWithImage:self.image];
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [scrollView addSubview:imageView];
    CGFloat imageWidth = CGImageGetWidth(self.image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(self.image.CGImage);
    float scaleX = self.cropSize.width / imageWidth;
    float scaleY = self.cropSize.height / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    scrollView.maximumZoomScale = scaleScroll*10.;
    scrollView.minimumZoomScale = scaleScroll;
    scrollView.contentSize = self.image.size;
    [scrollView setZoomScale:tempZoomScale animated:NO];
}

@end
