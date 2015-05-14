//
//  ParentObject.m
//  iParent
//
//  Created by michael on 13/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ParentObject.h"
#import "Assistant.h"
#import "Student.h"

@implementation ParentObject

- (id)init
{
    self = [super init];
    if (self) {
        _children_info      = [[NSMutableArray alloc] init];
        _ass_info           = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _children_info          = nil;
    _ass_info               = nil;
}

- (void)setChildren_info:(NSArray *)children_info
{
    [self.children_info removeAllObjects];
    
    for (NSDictionary *item in children_info) {
        Student *student = [[Student alloc] init];
        for (NSString *key in [item allKeys]) {
            if ([student respondsToSelector:NSSelectorFromString(key)]) {
                [student setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        [self.children_info  addObject:student];
    }
}

- (void)setAss_info:(NSArray *)ass_info
{
    [self.ass_info removeAllObjects];
    for (NSDictionary *item in ass_info) {
        Assistant *assitant = [[Assistant alloc] init];
        for (NSString *key in [item allKeys]) {
            if ([assitant respondsToSelector:NSSelectorFromString(key)]) {
                [assitant setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        [self.ass_info addObject:assitant];
    }
}

@end
