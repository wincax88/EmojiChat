//
//  ABPerson.h
//  BusinessGuy
//
//  Created by Matt Van Veenendaal on 8/24/12.
//  Copyright (c) 2012 Matt Van Veenendaal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ABPerson : NSObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) UIImage * portrait;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * email;
@property (nonatomic) ABRecordRef ref;

- (void) savePerson;

@end
