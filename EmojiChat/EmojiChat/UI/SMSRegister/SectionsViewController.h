

#import <UIKit/UIKit.h>

#import <SMS_SDK/CountryAndAreaCode.h>

@protocol SectionsViewControllerDelegate;

@interface SectionsViewController : UIViewController

@property (nonatomic, retain) id<SectionsViewControllerDelegate> delegate;

- (void)setAreaArray:(NSMutableArray*)array;

@end

@protocol SectionsViewControllerDelegate <NSObject>

- (void)setSecondData:(CountryAndAreaCode *)data;

@end


