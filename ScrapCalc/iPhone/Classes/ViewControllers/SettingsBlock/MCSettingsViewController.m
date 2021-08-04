//
//  MCSettingsViewController.m
//  ScrapCalc
//
//  Created by word on 11.04.13.
//
//

#import "MCSettingsViewController.h"
#import "MCCustomAssayViewController.h"
#import "MCCurrencyViewController.h"
#import "ModelManager.h"
#import "MCHomeScreenViewController.h"
#import "MCPushNotificationsViewController.h"
#import "MCPurchaseSettingsViewController.h"
#import "MCCompanyDetailsViewController.h"
#import "MCPrivacyPolicyViewController.h"

@implementation MCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationTitle:@"SETTINGS"];
    
    table_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    table_.backgroundColor = [UIColor clearColor];
    table_.backgroundView = nil;
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.dataSource = self;
    table_.delegate = self;
    
    
    [self.view addSubview:table_];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ModelManager shared] setDelegate:self];
    if (self.shouldPushPurchase) {
        self.shouldPushPurchase = NO;
        
        MCPurchaseSettingsViewController *vc = [MCPurchaseSettingsViewController new];
        [self.navigationController pushViewController:vc animated:NO];
        [vc release];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setScreenName:SETTINGS_SCREEN_NAME];
}

- (void)viewDidUnload
{
    [[ModelManager shared] setDelegate: nil];
    [table_ release];
    [super viewDidUnload];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SettingsSectionHomeScreen:
            return 1;
        case SettingsSectionCalculatorScreen:
            return 1;
        case SettingsSectionCurrencyScreen:
            return 1;
        case SettingsSectionCustomAssay:
            return 2;
        case SettingsSectionCompanyDetails:
            return 1;
        case SettingsSectionOther:
            return 5;
        default:
            return 0;
    }
}

- (UITableViewCell *)cellForHomeScreenAtRow:(NSInteger)row
{
    static NSString *cellID = @"Home_screen";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
    }
    cell.textLabel.text = @"Home screen";
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (UITableViewCell *)cellForCalculatorScreenAtRow:(NSInteger)row
{
    static NSString *cellID = @"SettingsCell-CalculatorScreen-ID";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
        
        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
        sw.onTintColor = [UIColor orangeColor];
        [sw addTarget:self action:@selector(showPercentChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        [sw release];
    }
    
    UISwitch *sw = (UISwitch *)cell.accessoryView;
    sw.on = [[[ModelManager shared] settings] showPercent] > 0;
    
    cell.textLabel.text = @"Show percent";
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForCurrencyScreenAtRow:(NSInteger)row
{
    static NSString *cellID = @"SettingsCell-Currency-ID";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
    }
    cell.textLabel.text = @"Currency";
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForCustomAssayAtRow:(NSInteger)row
{
    static NSString *cellID = @"SettingsCell-CustomAssay-ID";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
    }    
    cell.textLabel.text = (row == 0 ? @"Gold" : @"Silver");
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForCompanyDetailsAtRow:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SettingsCell-CompanyDetails-ID";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
    }
    cell.textLabel.text = @"Company Details";
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForOthersAtRow:(NSInteger)row
{
    static NSString *cellID = @"SettingsCell-Others-ID";
    UITableViewCell *cell = [table_ dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [cell setBackgroundView:bgView];
        [bgView release];
    }
    if(row == 0){
        cell.textLabel.text = @"Push Notifications";
    }
    else if(row == 1){
        cell.textLabel.text = @"Purchases";
    }
    else if(row == 2){
        cell.textLabel.text = @"Terms";
    }
    else if(row == 3){
        cell.textLabel.text = @"Privacy Policy";
    }
    else{
        cell.textLabel.text = @"Enter Code";
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section) {
        case SettingsSectionHomeScreen:
            return [self cellForHomeScreenAtRow:indexPath.row];
        case SettingsSectionCalculatorScreen:
            return [self cellForCalculatorScreenAtRow:indexPath.row];
        case SettingsSectionCurrencyScreen:
            return [self cellForCurrencyScreenAtRow:indexPath.row];
        case SettingsSectionCustomAssay:
            return [self cellForCustomAssayAtRow:indexPath.row];
        case SettingsSectionCompanyDetails:
            return [self cellForCompanyDetailsAtRow:indexPath.row];
        case SettingsSectionOther:
            return [self cellForOthersAtRow:indexPath.row];
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SettingsSectionHomeScreen:
            return @"Home Screen";
        case SettingsSectionCalculatorScreen:
            return @"Calculator Screen";
        case SettingsSectionCurrencyScreen:
            return @"Currency Screen";
        case SettingsSectionCustomAssay:
            return @"Custom Assay Adjustment";
        case SettingsSectionCompanyDetails:
            return @"Company Details";
        case SettingsSectionOther:
            return @"Other";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SettingsSectionCurrencyScreen) {
        MCCurrencyViewController *vc = [MCCurrencyViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    }
    else if (indexPath.section == SettingsSectionCustomAssay) {
        MCCustomAssayViewController *vc = [MCCustomAssayViewController new];
        vc.metal = [[ModelManager shared] metals][indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if (indexPath.section == SettingsSectionOther) {
        if (indexPath.row == 0) {
            MCPushNotificationsViewController *vc = [MCPushNotificationsViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else if(indexPath.row == 1){
            MCPurchaseSettingsViewController *vc = [MCPurchaseSettingsViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else if(indexPath.row == 2){
            // Terms
            MCPrivacyPolicyViewController *vc = [MCPrivacyPolicyViewController new];
            [vc setLoadHtmlName:@"terms"];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else if(indexPath.row == 3){
            // Privacy Policy
            MCPrivacyPolicyViewController *vc = [MCPrivacyPolicyViewController new];
            [vc setLoadHtmlName:@"privacy-policy"];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else{
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
    }
    else if(indexPath.section == SettingsSectionHomeScreen)
    {
        MCHomeScreenViewController *vc = [MCHomeScreenViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if (indexPath.section == SettingsSectionCompanyDetails)
    {
        MCCompanyDetailsViewController *vc = [MCCompanyDetailsViewController new];
        [self.navigationController pushViewController:vc animated:YES];
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
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma mark - Action

- (void)showPercentChanged:(UISwitch *)sender
{
    [[[ModelManager shared] settings] setShowPercent:(sender.isOn ? 1 : 0)];
    [[ModelManager shared] synchronizeSettings];
}

#pragma mark - Memory

- (void)dealloc
{
    [super dealloc];
}

@end
