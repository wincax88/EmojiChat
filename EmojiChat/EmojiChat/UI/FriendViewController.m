//
//  FriendViewController.m
//  EmojiChat
//
//  Created by michael on 25/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//


#import "FriendViewController.h"

#import "AppConstant.h"

#import <Parse/PFQuery.h>

#import <ParseUI/PFCollectionViewCell.h>

@interface FriendViewController ()

@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    layout.minimumInteritemSpacing = 5.0f;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    const CGRect bounds = UIEdgeInsetsInsetRect(self.view.bounds, layout.sectionInset);
    CGFloat sideSize = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 3.0f - layout.minimumInteritemSpacing;
    layout.itemSize = CGSizeMake(sideSize, sideSize);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Query

- (PFQuery *)queryForCollection {
    PFQuery *query = [super queryForCollection];
    [query orderByAscending:@"updateAt"];
    return query;
}

#pragma mark -
#pragma mark CollectionView

- (PFCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
                                  object:(PFObject *)object
{
    PFCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath object:object];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    PFUser *buddy = object[@"buddy"];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:buddy.objectId attributes:nil];
    cell.textLabel.attributedText = title;
    
    PFUser *user = [PFUser currentUser];
    
    [cell.imageView setFile:user[PF_USER_PICTURE]];
//    [cell.imageView loadInBackground];
    
    // If the image is nil - set the placeholder
    if (cell.imageView.image == nil) {
        cell.imageView.image = [UIImage imageNamed:@"icon_avatar_default"];
        [cell.imageView loadInBackground];
    }
    
    CGRect rect = cell.imageView.frame;
    rect.size.width = cell.contentView.bounds.size.width*0.8f;
    rect.size.height = rect.size.width;
    rect.origin.x = cell.contentView.bounds.size.width*0.1f;
    cell.imageView.frame = rect;
    cell.imageView.layer.cornerRadius = rect.size.height/2;
    cell.imageView.layer.masksToBounds = YES;

    cell.imageView.layer.borderWidth = 1.0f;
    cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    return cell;
}

@end
