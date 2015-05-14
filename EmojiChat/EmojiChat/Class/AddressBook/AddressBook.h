//
//  AddressBook.h
//  BusinessGuy
//
//  Created by Matt Van Veenendaal on 12/8/12.
//  Copyright (c) 2012 Matt Van Veenendaal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AddressBook : NSObject

+ (AddressBook *)sharedInstance;
- (void) addPhoto: (UIImage *)photo;
- (void) updateUnallocatedPhotos;
- (void) checkIfContactDeleted;

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, retain) NSMutableDictionary *photoDictionary;
@property (nonatomic, assign) ABRecordRef currentPerson;

@end
