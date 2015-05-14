//
//  FolderObject.m
//  iTao
//
//  Created by stephen on 14-8-12.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import "Folder.h"

@implementation Folder

- (id)init {
    if (self = [super init]) {
        _files = [[NSMutableArray alloc] init];
        _folders = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
