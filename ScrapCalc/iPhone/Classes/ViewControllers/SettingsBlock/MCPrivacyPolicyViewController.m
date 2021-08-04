//
//  MCPrivacyPolicyViewController.m
//  MetalCalcPlus
//
//  Created by Xian Huang on 2/17/20.
//

#import "MCPrivacyPolicyViewController.h"

@interface MCPrivacyPolicyViewController ()
@end



@implementation MCPrivacyPolicyViewController

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
        self.navigationItem.title = @"TERMS";
    else
        self.navigationItem.title = @"PRIVACY POLICY";

    [_m_webView setDelegate:self];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:_loadHtmlName ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_m_webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
- (void)dealloc {
    [_m_webView release];
    [super dealloc];
}
@end
