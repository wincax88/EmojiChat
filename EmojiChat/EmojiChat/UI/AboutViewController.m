//
//  AboutViewController.m
//  taozuoye
//
//  Created by michaelwong on 4/8/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "AboutViewController.h"
#import "HttpClient.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *urlLabel;

- (IBAction)onBackButtonTouched:(id)sender;

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本 V %@", version];
#ifdef DEBUG // for public test
    self.urlLabel.text = YBWEB_SERVER_URL;
#else
    self.urlLabel.hidden = YES;
    self.urlLabel.text = @"";
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)onBackButtonTouched:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

@end
