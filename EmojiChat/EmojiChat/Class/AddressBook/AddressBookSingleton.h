#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AddressBookSingleton : NSObject {
    
}
@property (nonatomic) ABAddressBookRef addressBook;

+ (id)sharedInstance;
@end
