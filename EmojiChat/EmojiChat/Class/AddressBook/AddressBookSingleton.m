#import "AddressBookSingleton.h"

@implementation AddressBookSingleton

@synthesize addressBook;

+(AddressBookSingleton *)sharedInstance {
    static dispatch_once_t pred;
    static AddressBookSingleton *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AddressBookSingleton alloc] init];
    });
    return shared;
}

- (ABAddressBookRef) getAddressBook {
    if (addressBook == nil) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
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
    }
    
    return addressBook;
}


@end