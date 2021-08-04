//
//  MCPrivacyPolicyViewController_iPad.m
//  MetalCalcPlus
//
//  Created by Xian Huang on 2/17/20.
//

#import "MCPrivacyPolicyViewController_iPad.h"

@interface MCPrivacyPolicyViewController_iPad ()

@end

@implementation MCPrivacyPolicyViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([self.loadHtmlName isEqualToString:@"terms"])
        self.titleLabel.text = @"TERMS";
    else
        self.titleLabel.text = @"PRIVACY POLICY";
    
    [self addBackButton];
    self.needsMoveBackButtonToTheContainer = YES;
    
     [_m_webView setDelegate:self];
     
     NSString *path = [[NSBundle mainBundle] pathForResource:_loadHtmlName ofType:@"html"];
     NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
     [_m_webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}



- (void)dealloc {
    [_m_webView release];
    [super dealloc];
}
@end
