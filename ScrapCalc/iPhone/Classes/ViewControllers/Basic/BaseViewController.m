//
//  BaseViewController.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "AppDelegate_iPhone.h"
#import "BaseViewController.h"
#import "MCSettingsViewController.h"
#import "MCPurchaseSettingsViewController.h"


@interface BaseViewController ()
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end


@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    if (IS_IOS7) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];        
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20] }];
    }
    
    UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-1, self.navigationController.navigationBar.frame.size.width, 2)];
    separatorImageView.image = [UIImage imageNamed:@"separator_full.png"];
    [self.navigationController.navigationBar addSubview:separatorImageView];
    [separatorImageView release];
    
    bgView_ = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    bgView_.image = [UIImage imageNamed:@"calc_background.png"];
    
    [self.view insertSubview:bgView_ atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [[VersionManager shared] setDidBecomeActive:NO];
}

- (void)dealloc
{
    [bgView_ release];
    
    self.activityIndicator = nil;
   
    [super dealloc];
}

- (void)setNavigationTitle:(NSString *)title
{
    self.navigationItem.title = title;
}


#pragma mark - BurstlyInterstitial

- (void)showAdIfNeeded
{
    if ([[VersionManager shared] needsAd]) {
        [self showInterstitialAd];
    }
}

- (void)showInterstitialAd
{
    if ([[ModelManager shared] isInmobiShown]) {
        return;
    }
    
    adsInmobi = [[IMInterstitial alloc] initWithAppId:INMOBI_APPID];

    [adsInmobi setDelegate:self];
    [adsInmobi loadInterstitial];
    
    [self displayActivityIndicator:YES];
}

- (void)displayActivityIndicator:(BOOL)doDisplay
{
    if (doDisplay && [self activityIndicator] == nil)
    {
        [self setActivityIndicator:[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease]];
        [[self activityIndicator] setCenter:CGPointMake([[self view] frame].size.width / 2.0, [[self view] frame].size.height / 1.7)];
        [[self activityIndicator] startAnimating];
        [[self view] addSubview:[self activityIndicator]];
    }
    else if (!doDisplay && [self activityIndicator] != nil)
    {
        [[self activityIndicator] removeFromSuperview];
        [self setActivityIndicator:nil];
    }
}

#pragma mark IMMOBI delegate
#pragma mark Interstitial Request Notifications

/**
 * Sent when an interstitial ad request succeeded.
 * @param ad The IMInterstitial instance which finished loading.
 */
- (void)interstitialDidReceiveAd:(IMInterstitial *)ad
{
    if([ad isKindOfClass:[IMInterstitial class]])   //inmobi
    {
        NSLog(@"An Interstitial Ad Request was successfully sent");
        if (adsInmobi.state == kIMInterstitialStateReady) {
            [adsInmobi presentInterstitialAnimated:YES];
        }    
    }
    else    //admob
    {
        if(adMob.isReady)
        {
            [adMob presentFromRootViewController:self];
        }
    }
}

/**
 * Sent when an interstitial ad request failed
 * @param ad The IMInterstitial instance which failed to load.
 * @param error The IMError associated with the failure.
 */
- (void)interstitial:(IMInterstitial *)ad
didFailToReceiveAdWithError:(IMError *)error
{
    NSLog(@"An Interstitial Ad Request was failed");
    NSLog(@"%@", error);
    
    if([ad isKindOfClass:[IMInterstitial class]])   //inmobi
    {
        //init admob ads
        adMob = [[GADInterstitial alloc] init];
        adMob.adUnitID = ADMOB_UNITID;
        adMob.delegate = self;
        [adMob loadRequest:[GADRequest request]];
    }
    else
    {
        [[ModelManager shared] setIsInmobiShown:NO];
        [self displayActivityIndicator:NO];
        [self showBuyNowAlert];        
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"AdMob was failed");
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    NSLog(@"AdMob was received");
}

#pragma mark Interstitial Interaction Notifications

/**
 * Sent just before presenting an interstitial.  After this method finishes the
 * interstitial will animate onto the screen.  Use this opportunity to stop
 * animations and save the state of your application in case the user leaves
 * while the interstitial is on screen (e.g. to visit the App Store from a link
 * on the interstitial).
 * @param ad The IMInterstitial instance which will present the screen.
 */
- (void)interstitialWillPresentScreen:(IMInterstitial *)ad
{
    [[ModelManager shared] setIsInmobiShown:YES];
    [self displayActivityIndicator:NO];
}

/**
 * Sent before the interstitial is to be animated off the screen.
 * @param ad The IMInterstitial instance which will dismiss the screen.
 */
- (void)interstitialWillDismissScreen:(IMInterstitial *)ad
{
    [[ModelManager shared] setIsInmobiShown:NO];
    [self displayActivityIndicator:NO];
    [self showBuyNowAlert];
}

/**
 * Called when the interstitial failed to display.
 * This should normally occur if the state != kIMInterstitialStateReady.
 * @param ad The IMInterstitial instance responsible for this error.
 * @param error The IMError associated with this failure.
 */
- (void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error
{
    NSLog(@"%@", [error description]);
    [[ModelManager shared] setIsInmobiShown:YES];
    [[ModelManager shared] setIsInmobiShown:NO];
    [self showBuyNowAlert];
}

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message okTitle:(NSString *)ok cancelTitle:(NSString *)cancel delegate:(id<UIAlertViewDelegate>)delegate
{
    [[[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancel otherButtonTitles:ok,nil] autorelease] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

static BOOL isBuyAlertShown = NO;

- (void)showBuyNowAlert
{

    if(isBuyAlertShown)
        return;

    if([VersionManager shared].currentVersion == VersionExpired
       && self.tabBarController.selectedIndex != 3){
        
        [self showAlertWithTitle:@"" andMessage:BUY_PRO_MESSAGE okTitle:@"Buy Now" cancelTitle:nil delegate:self];

        AppDelegate_iPhone* appDelegate = (AppDelegate_iPhone*) [UIApplication sharedApplication].delegate;
        for(UITabBarItem* item in appDelegate.tabBarController.tabBar.items){
            [item setEnabled:NO];                                       // disable when expire
        }
        [appDelegate.tabBarController setSelectedIndex:4];
        
        isBuyAlertShown = YES;
        return;
    }
    else
    {
        isBuyAlertShown = YES;
        [self showAlertWithTitle:@"" andMessage:BUY_PRO_MESSAGE okTitle:@"Buy Now" cancelTitle:@"Cancel" delegate:self];        
    }
}

- (void)showInternetAbsenceAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"The Internet connection appears to be offline."
                               delegate:nil
                      cancelButtonTitle:@"ОК"
                      otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self performSelector:@selector(gotoPurchaseScreen) withObject:nil afterDelay:0.1];
    }
}

- (void)gotoPurchaseScreen
{
    AppDelegate_iPhone* appDelegate = (AppDelegate_iPhone*) [UIApplication sharedApplication].delegate;
    [appDelegate.tabBarController setSelectedIndex:4];
    UINavigationController *nav = appDelegate.tabBarController.viewControllers[4];
    [nav popToRootViewControllerAnimated:NO];
    MCPurchaseSettingsViewController* vc = [MCPurchaseSettingsViewController new];
    [nav pushViewController:vc animated:NO];
}

- (void)initBackButton
{
    [self initBackButtonWithTitle:@"Back"];
}

- (void)initBackButtonWithTitle:(NSString *)title
{
    UIButton* backButton = [self _backButtonWithNormalImage:[UIImage imageNamed:@"btn_back_norm_iphone"] andSelectedImage:[UIImage imageNamed:@"btn_back_sel_iphone"] title:title textColor:[UIColor whiteColor]];
    [[backButton.widthAnchor constraintEqualToConstant:54] setActive:YES];
    [[backButton.heightAnchor constraintEqualToConstant:30] setActive:YES];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [[self navigationItem] setHidesBackButton:YES];
    [[self navigationItem] setLeftBarButtonItem:backButtonItem];
    [backButtonItem release];
}

- (void) initPrintButton
{
    UIButton* printButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [printButton addTarget:self action:@selector(onClickBtnPrint:) forControlEvents:UIControlEventTouchUpInside];
    [[printButton.widthAnchor constraintEqualToConstant:35] setActive:YES];
    [[printButton.heightAnchor constraintEqualToConstant:35] setActive:YES];
    [printButton setBackgroundImage:[UIImage imageNamed:@"purchase_print.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *printButtonItem = [[UIBarButtonItem alloc] initWithCustomView:printButton];
    [[self navigationItem] setRightBarButtonItem:printButtonItem];
}

- (void)onClickBtnPrint:(UIButton *)sender
{
    
}

- (UIButton *)_backButtonWithNormalImage:(UIImage *)normalImage andSelectedImage:(UIImage *)selectedImage title:(NSString *)title textColor:(UIColor *)textColor
{
    UIFont   *backButtonFont        = [UIFont boldSystemFontOfSize:12];    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[_backButton.widthAnchor constraintEqualToConstant:54] setActive:YES];
    [[_backButton.heightAnchor constraintEqualToConstant:30] setActive:YES];
    
    [_backButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_backButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    

    [[_backButton titleLabel] setFont:backButtonFont];
    [_backButton setTitle:title forState:UIControlStateNormal];
    return _backButton;
}

- (void)backButtonAction:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - Loading

- (void)showLoading
{
    [APP_DELEGATE showLoadingIndicator];
}

- (void)hideLoading
{
    [APP_DELEGATE hideLoadingIndicator];
}


@end
