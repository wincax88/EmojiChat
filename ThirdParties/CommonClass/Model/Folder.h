//
//  FolderObject.h
//  iTao
//
//  Created by stephen on 14-8-12.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Folder : NSObject

@property (nonatomic, copy) NSString* folderName;
@property (nonatomic, copy) UIImage* image;
@property (nonatomic, retain) NSMutableArray* files;
@property (nonatomic, retain) NSMutableArray* folders;

@end
