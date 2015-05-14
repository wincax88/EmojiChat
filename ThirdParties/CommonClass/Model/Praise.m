//
//  Praise.m
//  iStudent
//
//  Created by Stephen on 11/20/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Praise.h"

@implementation Praise

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)dealloc
{
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.reason forKey:@"reason"];
    [coder encodeObject:self.praise_num forKey:@"praise_num"];
    [coder encodeObject:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    self.reason = [decoder decodeObjectForKey:@"reason"];
    self.praise_num = [decoder decodeObjectForKey:@"praise_num"];
    self.type = [decoder decodeObjectForKey:@"type"];
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Praise *newObject = [[Praise alloc] init];
    
    newObject.timestamp          = self.timestamp;
    newObject.reason             = self.reason;
    newObject.praise_num         = self.praise_num;
    newObject.type               = self.type;
    
    return newObject;
}

@end
