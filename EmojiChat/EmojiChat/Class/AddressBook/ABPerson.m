//
//  ABPerson.m
//  BusinessGuy
//
//  Created by Matt Van Veenendaal on 8/24/12.
//  Copyright (c) 2012 Matt Van Veenendaal. All rights reserved.
//

#import "ABPerson.h"
#import "AddressBookSingleton.h"

@implementation ABPerson

- (void) savePerson {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED > 60000
    if (ABAddressBookRequestAccessWithCompletion != NULL){
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"Error");
                CFRelease(error);
            }
        });
    }
#endif
    
    CFErrorRef error = NULL;
    ABRecordRef newPerson = ABPersonCreate();
    
    if (self.firstName != nil)
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.firstName), &error);
    
    if (self.lastName != nil)
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(self.lastName), &error);

    if (self.company != nil)
        ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFTypeRef)(self.company), &error);
    
    if (self.mobile != nil)
    {
        ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(self.mobile), kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
        CFRelease(multiPhone);
    }
    
    if (self.email != nil)
    {
        ABRecordSetValue(newPerson, kABPersonEmailProperty,  (__bridge CFTypeRef)(self.email), &error);
    }
    
    ABAddressBookAddRecord(addressBook, newPerson, &error);
    
    ABAddressBookSave(addressBook, &error);
    CFRelease(newPerson);
    CFRelease(addressBook);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);        
    }
//    if (anError != nil)
//        CFRelease(anError);
}

@end
