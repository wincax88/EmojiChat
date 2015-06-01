//
//  ConfigureObject.h
//  iStudent
//
//  Created by michael on 27/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFFile;

@interface ConfigureObject : NSObject /*<NSCoding, NSCopying>*/

@property (nonatomic, strong) NSString* downUrl;
@property (nonatomic, strong) PFFile* emojiSound;

@end
