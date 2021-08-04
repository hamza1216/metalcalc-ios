//
//  MCPurchaseSettingsViewController.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCPurchaseSettingsViewController_iPad.h"
#import "DejalActivityView.h"
#import "InAppPurchaseProtocol.h"

@interface MCPurchaseSettingsViewController_iPad ()
{
    UILabel *statusLabel_;
    BOOL wantBuyPurchase_;
    
    NSArray *_products;
    BOOL _productsRequestFinished;
}

@property (nonatomic, assign) BOOL isPurchaseOrRestore;

@end


@implementation MCPurchaseSettingsViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"PURCHASES";
    
    statusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, self.table.frame.origin.y+10, self.containerView.bounds.size.width, 54)];
    statusLabel_.numberOfLines = 2;
    statusLabel_.backgroundColor = [UIColor clearColor];
    statusLabel_.textColor = [UIColor whiteColor];
    statusLabel_.font = FONT_MYRIAD_BOLD(18);
    statusLabel_.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:statusLabel_];
    
    CGRect frame = self.table.frame;
    frame.origin.y += 64;
    frame.size.height -= 64;
    self.table.frame = frame;
    
    if([VersionManager shared].currentVersion != VersionExpired){
        [self addBackButton];
        self.needsMoveBackButtonToTheContainer = YES;
    }
    
    if ([APP_DELEGATE iOS9OrHigher]) {
        _products = @[@"com.mikeburkard.metalcalcplus.1m",
                      @"com.mikeburkard.metalcalcplus.6m",
                      @"com.mikeburkard.metalcalcplus.1y"];
        
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Subscripting..." width:100];
        [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [DejalBezelActivityView removeViewAnimated:YES];
                _productsRequestFinished = YES;
            });
            
        } failure:^(NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [DejalBezelActivityView removeViewAnimated:YES];
            });
            
            NSLog([NSString stringWithFormat:@"Products Request Failed: %@", error.localizedDescription]);
        }];
    }
}

- (void)viewDidUnload
{
    [statusLabel_ release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([VersionManager shared].delegate == self) {
        [VersionManager shared].delegate = nil;
    }
    
    [super viewWillDisappear:animated];
}


- (void)updateStatus
{
    switch ([[VersionManager shared] currentVersion])
    {
        case VersionTrial:
        {
            statusLabel_.text = [NSString stringWithFormat:@"Trial version.\nExpires on %@", [self formattedDate:[[VersionManager shared] _expireDate]]];
            break;
        }
            
        case VersionDemo:
        {
            statusLabel_.text = [NSString stringWithFormat:@"Demo version.\nExpires on %@", [self formattedDate:[[VersionManager shared] _expireDate]]];
            break;
        }
            
        case VersionPro:
        {
            statusLabel_.text = [NSString stringWithFormat:@"Pro version.\nExpires on %@", [self formattedDate:[[VersionManager shared] _expireDate]]];
            break;
        }
            
        case VersionExpired:
        {
            statusLabel_.text = @"EXPIRED!\n Please subscribe to continue using the app.";
            break;
        }
            
        default:
            break;
    }
    [self.table reloadData];
}

- (NSString *)formattedDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
}

- (BOOL)needsBackground
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSettingsCell_iPad *cell = [[NSBundle mainBundle] loadNibNamed:@"MCSettingsCell_iPad" owner:self options:nil][0];
    cell.delegate = self;
    
    [self setupCell:cell forIndexPath:indexPath];
    
    cell.tag = indexPath.section * 1000 + indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)setupCell:(MCSettingsCell_iPad *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.cellType = MCSettingsCellTypeNone;
    if(indexPath.row == 5)
    {
        cell.titleLabel.text = @"Clear key chain";
    }
    else
    {
        cell.titleLabel.text = InAppPurchaseTitle(indexPath.row);
    }
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = indexPath.row;
    button.frame = CGRectMake(cell.frame.size.width - 115, (cell.frame.size.height - 50) / 2, 100, 46);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [button setTitle:(indexPath.row < 3 ? @"Buy" : @"Restore") forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"settings_content_button_orange.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    if(
       ([[VersionManager shared] currentVersion] == VersionPro
        || [[VersionManager shared] currentVersion] == VersionDemo)
       && indexPath.row != InAppPurchaseTypeRestoreAll
       && indexPath.row != 5)
    {
        [button setEnabled:NO];
    }
    else if([[VersionManager shared] currentVersion] == VersionPro
            && indexPath.row == InAppPurchaseTypeRestoreAll)
    {
        [button setEnabled:NO];
        
    } else {
        [button setEnabled:YES];
    }
    
    [[cell contentView] addSubview:button];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)buyButtonTouched:(UIButton *)sender
{
    NSLog(@"%d", sender.tag);
    
    if ([APP_DELEGATE iOS9OrHigher]) {
        if(sender.tag < 3) {
            
            if (![RMStore canMakePayments]) return;
            
            NSString* featureID = InAppPurchaseID(sender.tag);
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Subscripting..." width:100];
            [[RMStore defaultStore] addPayment:featureID success:^(SKPaymentTransaction *transaction) {
                
                if([[VersionManager shared] hasActiveSubscription]) {
                    [DejalBezelActivityView removeViewAnimated:YES];
                    
                    [[VersionManager shared] setDelegate:self];
                    [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                    
                    [ACTConversionReporter reportWithConversionID:kConversationID
                                                            label:kConversationLabel
                                                            value:kConversationValue
                                                     isRepeatable:YES];
                } else {
                    
                    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
                        
                        [[RMStore defaultStore] addPayment:featureID success:^(SKPaymentTransaction *transaction) {
                            
                            [DejalBezelActivityView removeViewAnimated:YES];
                            if([[VersionManager shared] hasActiveSubscription]) {
                                
                                [[VersionManager shared] setDelegate:self];
                                [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                                
                                [ACTConversionReporter reportWithConversionID:kConversationID
                                                                        label:kConversationLabel
                                                                        value:kConversationValue
                                                                 isRepeatable:YES];
                            }
                        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            
                            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                               message:error.localizedDescription
                                                                              delegate:nil
                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                     otherButtonTitles:nil];
                            [alerView show];
                        }];
                    } failure:^(NSError *error) {
                        
                        [DejalBezelActivityView removeViewAnimated:YES];
                        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                           message:error.localizedDescription
                                                                          delegate:nil
                                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                 otherButtonTitles:nil];
                        [alerView show];
                    }];
                }
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                [DejalBezelActivityView removeViewAnimated:YES];
                
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                   message:error.localizedDescription
                                                                  delegate:nil
                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                         otherButtonTitles:nil];
                [alerView show];
            }];
        } else if(sender.tag == 3
                  && ([VersionManager shared].currentVersion == VersionTrial || [VersionManager shared].currentVersion == VersionExpired) ) {
            
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Restoring..." width:100];
            [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
                
                [[VersionManager shared] setDelegate:self];
                if([[VersionManager shared] isSubscriptionPurchased])
                {
                    if([[VersionManager shared] hasActiveSubscription])
                    {
                        [DejalBezelActivityView removeViewAnimated:YES];
                        
                        [[VersionManager shared] setDelegate:self];
                        [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                    }
                    else {
                        
                        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
                            
                            [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
                                [DejalBezelActivityView removeViewAnimated:YES];
                                
                                [[VersionManager shared] setDelegate:self];
                                if([[VersionManager shared] isSubscriptionPurchased])
                                {
                                    if([[VersionManager shared] hasActiveSubscription])
                                    {
                                        [[VersionManager shared] setDelegate:self];
                                        [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                                    }
                                }
                                else if ([[VersionManager shared] hasOldVersion]) {
                                    
                                    [[VersionManager shared] setDelegate:self];
                                    [[VersionManager shared] _storeNewKeyChainWithVersion:VersionDemo];
                                }
                                else {
                                    
                                    [super showAlertWithTitle:@"Sorry" andMessage:@"You have not activate purchase item"];
                                }
                                
                            } failure:^(NSError *error) {
                                [DejalBezelActivityView removeViewAnimated:YES];
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"")
                                                                                    message:error.localizedDescription
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }];
                        } failure:^(NSError *error) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"")
                                                                                message:error.localizedDescription
                                                                               delegate:nil
                                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                      otherButtonTitles:nil];
                            [alertView show];
                        }];
                        
                        [super showAlertWithTitle:@"Sorry" andMessage:@"You have not activate purchase item"];
                    }
                }
                else if ([[VersionManager shared] hasOldVersion]) {
                    [DejalBezelActivityView removeViewAnimated:YES];
                    
                    [[VersionManager shared] setDelegate:self];
                    [[VersionManager shared] _storeNewKeyChainWithVersion:VersionDemo];
                }
                else {
                    [DejalBezelActivityView removeViewAnimated:YES];
                    
                    [super showAlertWithTitle:@"Sorry" andMessage:@"You have not activate purchase item"];
                }
                
            } failure:^(NSError *error) {
                [DejalBezelActivityView removeViewAnimated:YES];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"")
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];
                [alertView show];
            }];
        } else if(sender.tag == 4){
            
            [[RMStore defaultStore] addPayment:@"com.mikeburkard.metalcalcplus.proversion" success:^(SKPaymentTransaction *transaction) {
                
                NSLog(@"Got old pro version");
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                
                NSLog(@"failure");
            }];
        } else if(sender.tag == 5){
            [[VersionManager shared] clearKeyChain];
        }
    } else {
        if(sender.tag < 3) {
            
            NSString* featureID = InAppPurchaseID(sender.tag);
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Subscripting..." width:100];
            [[MKStoreManager sharedManager] buyFeature:featureID
                                            onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
                                                [DejalBezelActivityView removeViewAnimated:YES];
                                                
                                                if([[VersionManager shared] hasActiveSubscription]) {
                                                    [[VersionManager shared] setDelegate:self];
                                                    [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                                                    
                                                    [ACTConversionReporter reportWithConversionID:kConversationID
                                                                                            label:kConversationLabel
                                                                                            value:kConversationValue
                                                                                     isRepeatable:YES];
                                                }
                                            }
                                           onCancelled:^{
                                               
                                               NSLog(@"false");
                                               [DejalBezelActivityView removeViewAnimated:YES];
                                               [super showAlertWithTitle:@"Sorry" andMessage:@"You can't purchase this item now."];
                                           }];
            
        } else if(sender.tag == 3
                  && ([VersionManager shared].currentVersion == VersionTrial || [VersionManager shared].currentVersion == VersionExpired) ) {
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Restoring..." width:100];
            [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
                [DejalBezelActivityView removeViewAnimated:YES];
                
                [[VersionManager shared] setDelegate:self];
                if([[VersionManager shared] isSubscriptionPurchased])
                {
                    if([[VersionManager shared] hasActiveSubscription])
                    {
                        [[VersionManager shared] setDelegate:self];
                        [[VersionManager shared] _storeNewKeyChainWithVersion:VersionPro];
                    }
                    else
                        [super showAlertWithTitle:@"Sorry" andMessage:@"You have not activate purchase item"];
                }
                else if ([[VersionManager shared] hasOldVersion]) {
                    [[VersionManager shared] setDelegate:self];
                    [[VersionManager shared] _storeNewKeyChainWithVersion:VersionDemo];
                }
                else
                    [super showAlertWithTitle:@"Sorry" andMessage:@"You have not activate purchase item"];
                
            } onError:^(NSError *error) {
                NSLog(@"Restore Transaction Error!");
                [DejalBezelActivityView removeViewAnimated:YES];
                [self showAlertWithTitle:@"Oops!" andMessage:@"Your restore transaction was failed"];
            }];
        } else if(sender.tag == 4){
            [[MKStoreManager sharedManager] buyFeature:@"com.mikeburkard.metalcalcplus.proversion"
                                            onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
                                                
                                                NSLog(@"Got old pro version");
                                                
                                            }
                                           onCancelled:^{
                                               
                                               NSLog(@"failure");
                                               
                                           }];
            
        } else if(sender.tag == 5){
            [[VersionManager shared] clearKeyChain];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Version

- (void)versionManagerDidFinishVerification
{
    [self updateStatus];
    [self hideLoading];
    
    if (self.isPurchaseOrRestore) {
        [self showAlertWithTitle:@"Transaction successful" andMessage:@"You are now using Pro version"];
    }
    else {
        [self showAlertWithTitle:@"Transaction successful" andMessage:@"Your purchases have been restored"];
    }
    
    if([VersionManager shared].currentVersion != VersionExpired){
        AppDelegate_iPad* appDelegate_iPad = (AppDelegate_iPad*)[UIApplication sharedApplication].delegate;
        for(UIButton* button in appDelegate_iPad.toolbarView.tabBar.buttons){
            [button setEnabled:YES];
        }
        [self addBackButton];
    }
}

@end
