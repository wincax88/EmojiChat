//
//  AddressBook.m
//  BusinessGuy
//
//  Created by Matt Van Veenendaal on 12/8/12.
//  Copyright (c) 2012 Matt Van Veenendaal. All rights reserved.
//

#import "AddressBook.h"

@implementation AddressBook

AddressBook *_sharedObject;

+ (AddressBook *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id) init {
    if (!(self = [super init])) return self;
    self.photoDictionary = [NSMutableDictionary dictionary];
    return self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEvent:) name:@"gotRecordNumber" object:nil];

}

- (void) addPhoto: (UIImage *)photo {
    //write photo to disk and save the address in the array:
    NSMutableArray *photoList;
    NSLog(@"Adding Photo to PersonID: %@", self.currentPerson);
    ABRecordID recordID = ABRecordGetRecordID(self.currentPerson);

    NSNumber *recordNumber = [NSNumber numberWithInt:recordID];
    
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.8);
    NSString *savePath = uniqueSavePath();
    [imageData writeToFile:savePath atomically:YES];
    
    if ([self.photoDictionary objectForKey:recordNumber])
        photoList = (NSMutableArray *) [self.photoDictionary objectForKey:recordNumber];
    else {
        photoList = [NSMutableArray array];
        [self.photoDictionary setObject:photoList forKey:recordNumber];
    }
    
    [photoList addObject:savePath];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[AddressBook sharedInstance].photoDictionary];
    [userDefaults setObject:data forKey:@"photoDictionary"];
    [userDefaults synchronize];
}

- (void) updateUnallocatedPhotos {
    if ([self.photoDictionary objectForKey:[NSNumber numberWithInt:-1]]) {
        NSLog(@"We have photos in the non number! Move to the new number!");
        ABRecordID recordID = ABRecordGetRecordID(self.currentPerson);
        NSNumber *recordNumber = [NSNumber numberWithInt:recordID];
        if (recordNumber != [NSNumber numberWithInt:-1]) {
            NSLog(@"We have a new Person!");
            [self.photoDictionary setObject:[self.photoDictionary objectForKey:[NSNumber numberWithInt:-1]] forKey:recordNumber];
            //clear the photos that were around.
            [self.photoDictionary removeObjectForKey:[NSNumber numberWithInt:-1]];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[AddressBook sharedInstance].photoDictionary];
            [userDefaults setObject:data forKey:@"photoDictionary"];
            [userDefaults synchronize];
        }
    }
}

- (void)receiveEvent:(NSNotification *)notification {
    NSNumber *recordNumber = [[notification userInfo] valueForKey:@"recordNumber"];
    
    NSMutableArray *photoList;
    if ([self.photoDictionary objectForKey:recordNumber])
        photoList = (NSMutableArray *) [self.photoDictionary objectForKey:recordNumber];
    else {
        photoList = [NSMutableArray array];
        [self.photoDictionary setObject:photoList forKey:recordNumber];
    }
    
    NSArray *oldPhotos = [self.photoDictionary objectForKey:[NSNumber numberWithInt:-1]];
    [photoList addObjectsFromArray:oldPhotos];
    [self.photoDictionary removeObjectForKey:[NSNumber numberWithInt:-1]];
}

NSString *uniqueSavePath() {
    int i = 1;
    NSString *path;
    do {
        //iterate until a name does not match an existing file:
        path = [NSString stringWithFormat:@"%@/Documents/IMAGE_%04d.jpg", NSHomeDirectory(), i++];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    
    return path;
}


- (void)checkIfContactDeleted {
    for (NSNumber *recordNumber in [self.photoDictionary allKeys]) {
        ABRecordID  recordID = (ABRecordID) [recordNumber intValue];
        ABRecordRef person = ABAddressBookGetPersonWithRecordID([AddressBook sharedInstance].addressBook, recordID);
        ABRecordID newRecordId = ABRecordGetRecordID(person);
        NSNumber *checkedNumber = [NSNumber numberWithInt:newRecordId];
        if (checkedNumber == [NSNumber numberWithInt:-1]) {
            [self.photoDictionary removeObjectForKey:recordNumber];
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[AddressBook sharedInstance].photoDictionary];
    [userDefaults setObject:data forKey:@"photoDictionary"];
    [userDefaults synchronize];
}

@end
