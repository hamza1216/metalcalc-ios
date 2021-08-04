//
//  MCSettingsViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCSettingsViewController_iPad.h"
#import "MCHomeScreenViewController_iPad.h"
#import "MCCustomAssayViewController_iPad.h"
#import "MCPushNotificationsViewController_iPad.h"
#import "MCPurchaseSettingsViewController_iPad.h"
#import "MCCurrencyViewController_iPad.h"
#import "MCCompanyDetailsViewController_iPad.h"
#import "MCPrivacyPolicyViewController_iPad.h"

@interface MCSettingsViewController_iPad ()

@end


@implementation MCSettingsViewController_iPad

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ModelManager shared] setDelegate:self];
    
    [self setLeftToolBarButtonHidden:YES];
    [self setRightToolBarButtonHidden:YES];
    [self.table reloadData];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MCSettingsSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case MCSettingsSectionTypeHomeScreen:
            return 1;
        case MCSettingsSectionTypeCalculator:
            return 1;
        case MCSettingsSectionTypeCustomAssay:
            return MCSettingsCustomAssayTypeCount;
        case MCSettingsSectionTypeCompanyDetails:
            return 1;
        case MCSettingsSectionTypeOther:
            return MCSettingsOtherTypeCount;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const cellID = @"MCSettingsCell_iPadID";
    MCSettingsCell_iPad *cell = (MCSettingsCell_iPad *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCSettingsCell_iPad" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    [self setupCell:cell forIndexPath:indexPath];
    
    cell.tag = indexPath.section * 1000 + indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)setupCell:(MCSettingsCell_iPad *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    switch (indexPath.section) {
        case MCSettingsSectionTypeHomeScreen:
        {
            cell.cellType = MCSettingsCellTypeDisclosure;
            cell.titleLabel.text = @"Home Screen";
            break;
        }
            
        case MCSettingsSectionTypeCalculator:
        {
            cell.cellType = MCSettingsCellTypeOnOff;
            cell.titleLabel.text = @"Show Percent";
            cell.isChecked = [[[ModelManager shared] settings] showPercent] > 0;
            break;
        }
            
        case MCSettingsSectionTypeCustomAssay:
        {
            cell.cellType = MCSettingsCellTypeDisclosure;
            cell.titleLabel.text = (row == MCSettingsCustomAssayTypeGold ? @"Gold" : @"Silver");
            break;
        }
            
        case MCSettingsSectionTypeCompanyDetails:
        {
            cell.cellType = MCSettingsCellTypeDisclosure;
            cell.titleLabel.text = @"Company Details";
            break;
        }
            
        case MCSettingsSectionTypeOther:
        {
            cell.cellType = MCSettingsCellTypeDisclosure;
            switch (indexPath.row) {
                case MCSettingsOtherTypePurchases:
                    cell.titleLabel.text = @"Purchases";
                    break;
                case MCSettingsOtherTypePushNotifications:
                    cell.titleLabel.text = @"Push Notifications";
                    break;
                case MCSettingsOtherTypeCurrency:
                    cell.titleLabel.text = @"Currency";
                    break;
                case MCSettingsOtherTerms:
                    cell.titleLabel.text = @"Terms";
                    break;
                case MCSettingsOtherPrivacyPolicy:
                    cell.titleLabel.text = @"Privacy Policy";
                    break;
                case MCSettingsOtherEnterCode:
                    cell.titleLabel.text = @"Enter Code";
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}

static const CGFloat headerHeight = 45;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = self.table.frame;
    frame.origin.y = 0;
    frame.size.height = headerHeight - 3;
    
    UIView *headerView = [[[UIView alloc] initWithFrame:frame] autorelease];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgImage.image = [UIImage imageNamed:@"settings_header_background.png"];
    [headerView addSubview:bgImage];
    [bgImage release];
    
    CGRect textFrame = headerView.bounds;
    textFrame.origin.x += 20;
    textFrame.origin.y += 4;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textFrame];
    textLabel.tag = 10;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.shadowColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0, 1);
    textLabel.font = FONT_MYRIAD_SEMIBOLD(32);
    [headerView addSubview:textLabel];
    
    switch (section)
    {
        case MCSettingsSectionTypeHomeScreen:
            textLabel.text = @"Home Screen";
            break;
            
        case MCSettingsSectionTypeCalculator:
            textLabel.text = @"Calculator Screen";
            break;
            
        case MCSettingsSectionTypeCustomAssay:
            textLabel.text = @"Custom Assay Adjustment";
            break;
            
        case MCSettingsSectionTypeCompanyDetails:
            textLabel.text = @"Company Details";
            break;
            
        case MCSettingsSectionTypeOther:
            textLabel.text = @"Other";
            break;
        default:
            break;
    }
    
    [textLabel release];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

#pragma mark - UITableView Delegate

- (void)deselectPath:(NSIndexPath *)indexPath
{
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(deselectPath:) withObject:indexPath afterDelay:0.5];
    
    switch (indexPath.section)
    {
        case MCSettingsSectionTypeHomeScreen:
        {
            MCHomeScreenViewController_iPad *vc = [[MCHomeScreenViewController_iPad alloc] initWithNibName:@"MCSettingsViewController_iPad" bundle:nil];
            [self.navigationViewController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
            
        case MCSettingsSectionTypeCalculator:
        {
            [[[ModelManager shared] settings] setShowPercent:![[[ModelManager shared] settings] showPercent]];
            [[ModelManager shared] synchronizeSettings];
            [self.table reloadData];
            break;
        }
            
        case MCSettingsSectionTypeCustomAssay:
        {
            MCCustomAssayViewController_iPad *vc = [[MCCustomAssayViewController_iPad alloc] initWithNibName:nil bundle:nil];
            vc.metal = [[ModelManager shared] metals][indexPath.row];
            [self.navigationViewController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
            
        case MCSettingsSectionTypeCompanyDetails:
        {
            MCCompanyDetailsViewController_iPad *vc = [[MCCompanyDetailsViewController_iPad alloc] initWithNibName:@"MCCompanyDetailsViewController_iPad" bundle:nil];
            [self.navigationViewController pushViewController:vc animated:YES];
            break;
        }
            
        case MCSettingsSectionTypeOther:
        {
            switch (indexPath.row) {
                case MCSettingsOtherTypePushNotifications:
                {
                    MCPushNotificationsViewController_iPad *vc = [[MCPushNotificationsViewController_iPad alloc] initWithNibName:nil bundle:nil];
                    [self.navigationViewController pushViewController:vc animated:YES];
                    [vc release];
                }
                    break;
                case MCSettingsOtherTypePurchases:
                {
                    MCPurchaseSettingsViewController_iPad *vc = [[MCPurchaseSettingsViewController_iPad alloc] initWithNibName:@"MCSettingsViewController_iPad" bundle:nil];
                    [self.navigationViewController pushViewController:vc animated:YES];
                    [vc release];
                }
                    break;
                case MCSettingsOtherTypeCurrency:
                {
                    if ([[VersionManager shared] canFetchData]) {
                        MCCurrencyViewController_iPad *vc = [MCCurrencyViewController_iPad new];
                        [self.navigationViewController pushViewController:vc animated:YES];
                        [vc release];
                    }
                    else {
                        [[[ModelManager shared] settings] setCurrencyID:@"88"];
                        [[ModelManager shared] synchronizeSettings];
                        [self showAlertWithTitle:@"" andMessage:BUY_PRO_MESSAGE okTitle:@"Buy Now" cancelTitle:@"Cancel" delegate:self];
                    }
                }
                    break;
                case MCSettingsOtherTerms:
                {
                    MCPrivacyPolicyViewController_iPad *vc = [[MCPrivacyPolicyViewController_iPad alloc] initWithNibName:nil bundle:nil];
                    [vc setLoadHtmlName:@"terms"];
                    [self.navigationViewController pushViewController:vc animated:YES];
                    [vc release];

                }
                    break;
                case MCSettingsOtherPrivacyPolicy:
                {
                    MCPrivacyPolicyViewController_iPad *vc = [[MCPrivacyPolicyViewController_iPad alloc] initWithNibName:nil bundle:nil];
                    [vc setLoadHtmlName:@"privacy-policy"];
                    [self.navigationViewController pushViewController:vc animated:YES];
                    [vc release];
                }
                    break;
                case MCSettingsOtherEnterCode:
                {
                    // Enter Code
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Code" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITextField* inputTextField = [[alert textFields] objectAtIndex:0];
                        NSString* inputCode = inputTextField.text;
                        NSLog(@"Enter Code Dialog: Text -> %@", inputCode);
                        // Check if it is valid key
                        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Veiryfing KeyCode..." width:100];
                        [[ModelManager shared] verifyKeyCode:inputCode];
                        
                    }]];//
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        
                    }];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}
- (void)didVerifieyKeyCode:(NSInteger)code
{
    [DejalBezelActivityView removeViewAnimated:YES];
    if(code == 0){
        [super showAlertWithTitle:@"" andMessage:@"KeyCode Verification Success."];
        [[VersionManager shared] _storeNewKeyChainWithVersion:VersionKeyCode];
    }
    else{
        [super showAlertWithTitle:@"" andMessage:@"KeyCode Verification Failed."];
    }
    NSLog(@"KeyCode verified: %d", code);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTINGS_CELL_HEIGHT;
}

- (void)pushPurchaseScreen
{
    MCPurchaseSettingsViewController_iPad *vc = [[MCPurchaseSettingsViewController_iPad alloc] initWithNibName:@"MCSettingsViewController_iPad" bundle:nil];
    [self.navigationViewController pushViewController:vc animated:NO];
    [vc release];
}


#pragma mark - Cell Delegate

- (void)cell:(MCSettingsCell_iPad *)cell didChangeValue:(BOOL)newValue
{
    NSInteger section = cell.tag / 1000;
    
    if (section == MCSettingsSectionTypeCalculator) {
        [[[ModelManager shared] settings] setShowPercent:(newValue ? 1 : 0)];
        [[ModelManager shared] synchronizeSettings];
    }
}

- (BOOL)needsBackground
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.table reloadData];
}

@end
