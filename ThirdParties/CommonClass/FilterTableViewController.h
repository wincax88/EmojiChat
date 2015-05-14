//
//  FilterTableViewController.h
//  iStudent
//
//  Created by stephen on 9/25/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterTableViewControllerDelegate <NSObject>

- (void)filterSelectedWithString:(NSString*)string;

@end

@interface FilterTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
}

@property (nonatomic, retain) NSMutableArray* filterArray;
@property (nonatomic, retain) NSMutableArray* filterTextColor;
@property (nonatomic, assign) id <FilterTableViewControllerDelegate> delegate;

- (id) initWithStyle:(UITableViewStyle)style frame:(CGRect)frame;
@end
