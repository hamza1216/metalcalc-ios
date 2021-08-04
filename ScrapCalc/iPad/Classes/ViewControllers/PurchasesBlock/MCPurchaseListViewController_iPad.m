//
//  MCPurchaseListViewController.m
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import "MCPurchaseListViewController_iPad.h"
#import "MCPurchaseCell_iPad.h"
#import "CkoCsv.h"

@interface MCPurchaseListViewController_iPad ()
{
    BOOL needToHideLabelAddPurchase_;
}

@property (nonatomic, retain) IBOutlet UIButton *addPurchaseButton;
@property (nonatomic, retain) IBOutlet UIButton *exportCSV;
@property (nonatomic, retain) IBOutlet UILabel *addPurchaseLabel;

@property (nonatomic, retain) Purchase *selectedPurchase;

- (IBAction)addPurchase:(id)sender;
- (IBAction)onClickBtnExportCSV:(id)sender;

@end

#define HEADER_HEIGHT       45.0

@implementation MCPurchaseListViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    items_ = [NSMutableDictionary new];
    keys_ = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupPurchases];
    [self.table reloadData];
    if(self.associateClient)
        [self addBackButton];
}

- (void)viewDidUnload
{
    [items_ release];
    [keys_ release];
    [self setSelectedPurchase:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - actions

- (void)addPurchase:(id)sender
{
    self.selectedPurchase = nil;
    [[[self splitViewController] toolbar] selectTabIndex:0];
}

-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"PMCP Purchases.csv"];
}

- (void)createCSVFile
{
    [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath] contents:nil attributes:nil];
    CkoCsv *csv = [[CkoCsv alloc] init];
    
    csv.HasColumnNames = YES;
    [csv SetColumnName:[NSNumber numberWithInt:0] columnName:@"Client Name"];
    [csv SetColumnName:[NSNumber numberWithInt:1] columnName:@"Purchase Number"];
    [csv SetColumnName:[NSNumber numberWithInt:2] columnName:@"Weight"];
    [csv SetColumnName:[NSNumber numberWithInt:3] columnName:@"Unit"];
    [csv SetColumnName:[NSNumber numberWithInt:4] columnName:@"Purity"];
    [csv SetColumnName:[NSNumber numberWithInt:5] columnName:@"Metal"];
    [csv SetColumnName:[NSNumber numberWithInt:6] columnName:@"Date"];
    [csv SetColumnName:[NSNumber numberWithInt:7] columnName:@"Value"];
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    
    [writeString appendString:@"ClientName PurchaseNumber Weight Unit Purity Metal Date Value \n"];
    
    int nRow = 0;
    
    for (NSString *key in keys_)
    {
        for(Purchase *purchase in items_[key])
        {
            NSString *strClientName = [[ModelManager shared] clientNameByID:purchase.clientID];
            NSString *strPurchaseNumber = purchase.number;
            for(PurchaseItem *purchaseItem in purchase.items)
            {
                NSString *strWeight = [NSString stringWithWeight:purchaseItem.weight];
                NSString *strUnit = purchaseItem.unit.shortName.uppercaseString;
                NSString *strPurityName = purchaseItem.purityName;
                NSString *strMetal = purchaseItem.metal.name.uppercaseString;
                NSString *strPrice = [NSString stringWithPrice:purchaseItem.price];
                
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:0] content:strClientName];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:1] content:strPurchaseNumber];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:2] content:strWeight];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:3] content:strUnit];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:4] content:strPurityName];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:5] content:strMetal];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:6] content:key];
                [csv SetCell:[NSNumber numberWithInt:nRow] col:[NSNumber numberWithInt:7] content:strPrice];
                
                nRow++;
            }
        }
    }
    
    BOOL success;
    success = [csv SaveFile:[self dataFilePath]];
    
    if(!success)
    {
        NSLog(@"%@", csv.LastErrorText);
    }
}

- (IBAction)onClickBtnExportCSV:(id)sender
{
    [self createCSVFile];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Metal Calc"];
    
    [mc addAttachmentData:[NSData dataWithContentsOfFile:[self dataFilePath]]
                 mimeType:@"text/csv"
                 fileName:@"PMCP Purchases.csv"];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *txtEmailResult;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            txtEmailResult = @"Mail Cancelled";
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            txtEmailResult = @"Mail Saved";
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            txtEmailResult = @"Mail sent successfully";
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            txtEmailResult = [error description];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email"
                                                    message:txtEmailResult
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark - private 

- (void)setupPurchases
{
    [items_ removeAllObjects];
    [keys_ removeAllObjects];
    
    NSArray *purchases = [[[ModelManager shared] purchases] sortedArrayUsingComparator:^NSComparisonResult(Purchase *obj1, Purchase *obj2) {
        if (obj1.timestamp < obj2.timestamp) {
            return NSOrderedDescending;
        }
        if (obj1.timestamp > obj2.timestamp) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    for (Purchase *purchase in purchases) {
        if (!purchase.isApproved)
            continue;
        
        NSString *key = purchase.datetime;
        if (items_[key] == nil) {
            items_[key] = [NSMutableArray array];
            [keys_ addObject:key];
        }
        [items_[key] addObject:purchase];
    }
    
    for (NSString *key in keys_) {
        items_[key] = [items_[key] sortedArrayUsingSelector:@selector(compare:)];
    }
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return keys_.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items_[keys_[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return keys_[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGRect frame = CGRectMake(0, 0, cell.frame.size.width, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];;
    UIImageView *headerBg = [[UIImageView alloc] initWithFrame:frame];
    headerBg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)||self.associateClient)
    {
        headerBg.image = [UIImage imageNamed:@"purchases_content_textheader_back"];
    }
    else
    {
        headerBg.image = [UIImage imageNamed:@"purchases_content_textheader_back_short"];
    }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 2, 300.0, 41.0)];
    [title setFont:[UIFont boldSystemFontOfSize:22.0]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:keys_[section]];
    [headerView addSubview:headerBg];
    [headerView addSubview:title];
    [title release];
    [headerBg release];
    return [headerView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PurchasesCell";
    MCPurchaseCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[MCPurchaseCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    Purchase *purchase = items_[keys_[indexPath.section]][indexPath.row];
    cell.number = purchase.number;
    cell.client = [[ModelManager shared] clientNameByID:purchase.clientID];
    [cell updatePurchaseCell:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)||self.associateClient];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PURCHASE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) || self.associateClient)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Purchase *purchase = items_[keys_[indexPath.section]][indexPath.row];
    
    if (self.associateClient) {
        self.selectedPurchase = purchase;
        
        if (purchase.clientID.integerValue > 0) {
            if ([self.associateClient.clientID isEqualToString:purchase.clientID]) {
                [self showAlertWithTitle:@"" andMessage:@"The Purchase is already associated with this Client"];
            }
            else {
                [self showAlertWithTitle:@"" andMessage:@"The Purchase is associated with another Client. Would you like to associate it with this Client instead?" okTitle:@"Yes" cancelTitle:@"Cancel" delegate:self];
            }
        }
        else {
            [self associatePurchaseAndPop];
        }
    }
    else {
        self.selectedPurchase = purchase;
        [[self delegate] purchaseListDidSelectPurchase:purchase];
        [self.splitViewController pushDetailAnimated:YES];
    }
}

- (void)associatePurchaseAndPop
{
    self.selectedPurchase.clientID = self.associateClient.clientID;
    [[ModelManager shared] updatePurchaseWithNewClient:self.selectedPurchase];
    [self.navigationViewController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [self associatePurchaseAndPop];
    }
}

#pragma mark - overrides

- (void)actionForLeftButtonOnTheToolBar
{
    [self onClickBtnExportCSV:nil];
}

- (void)actionForRightButtonOnTheToolBar
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    if(!pic)
    {
        NSLog(@"Couldn't get shared UIPrintInteractionController, need iOS 4.2 or up!");
        return;
    }
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Sample";
    pic.printInfo = printInfo;
    
    NSString *htmlString = [self makeHTMLTextForAirPrint];
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlString];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(30.0, 30.0, 30.0, 30.0);
    htmlFormatter.maximumContentWidth = 7 * 72.0;   // printed content should be 6-inches wide within those margins
//    htmlFormatter.maximumContentHeight = htmlFormatter.maximumContentWidth * 1.5f;
    pic.printFormatter = htmlFormatter;
//    [htmlFormatter release];
    
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) 
    {
        if (!completed && error) 
        {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        //self.m_barBtnPrint
        [pic presentFromRect:CGRectMake(self.view.frame.size.height / 4, self.view.frame.size.width / 1.5f, self.view.frame.size.height / 2, self.view.frame.size.width)
                      inView:self.view
                    animated:true
           completionHandler:completionHandler];
        //        [pic presentFromBarButtonItem:nil animated:YES completionHandler:completionHandler];
    } 
    else
    {
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}



#pragma mark - Setup for Interface Orientation

- (void)setupForPortrait
{   
    [super setupForPortrait];
    [self setLeftToolBarButtonHidden:YES];
    if(self.associateClient)
    {
        self.needsMoveBackButtonToTheContainer = YES;
        [self addBackButton];
        [[self addPurchaseButton] setHidden:YES];
        [[self exportCSV] setHidden:YES];
    }
    else
    {
        [self removeBackButton];
        [[self addPurchaseButton] setHidden:NO];
        [[self exportCSV] setHidden:NO];
    }
    [self.addPurchaseLabel setHidden:YES];
    self.table.frame = CLIENT_TABLE_FRAME_PORTRAIT;
    [[self table] reloadData];
}

- (void)setupForLandscape
{
    [super setupForLandscape];
    if(self.associateClient)
    {
        [self setLeftToolBarButtonHidden:YES];
        [self.addPurchaseLabel setHidden:YES];
        
        [self setRightToolBarButtonHidden:YES];
        
        self.table.frame = CLIENT_TABLE_FRAME_LANDSCAPE_WITH_BACK;
        self.needsMoveBackButtonToTheContainer = YES;
        [self addBackButton];
    }
    else
    {
        [self setLeftToolBarButtonHidden:needToHideLabelAddPurchase_];
        [self.addPurchaseLabel setHidden:needToHideLabelAddPurchase_];
        
        [self setRightToolBarButtonHidden:NO];
        
        self.table.frame = CLIENT_TABLE_FRAME_LANDSCAPE;
        [self removeBackButton];
        [self removePrintButton];
    }
    [[self addPurchaseButton] setHidden:YES];
    [[self exportCSV] setHidden:YES];
    [[self table] reloadData];
    if(self.selectedPurchase)
    {
        [self selectRowInTableView:[self table] whichContainsPurchase:self.selectedPurchase];
    }
}


#pragma mark - MCPurchaseDetailsViewControllerDelegate

- (void)setAddPurchaseButtonHidden:(BOOL)hidden
{
    needToHideLabelAddPurchase_ = hidden;
    [self setLeftToolBarButtonHidden:hidden];
    [self.addPurchaseLabel setHidden:hidden];
}

#pragma mark - left toolbar button

- (UIImage *)imageForLeftToolBarButton
{
    return [UIImage imageNamed:@"purchase_export_csv.png"];
}

- (CGRect)imageRectForLefToolBarButton
{
    return CGRectMake(17.0f, 12.0f, 50, 40);
}

- (UIImage *)imageForRightToolBarButton
{
    return [UIImage imageNamed:@"purchase_print.png"];
}

- (CGRect)imageRectForRightToolBarButton
{
    return CGRectMake(960.0f, 5.0f, 40, 40);
}

-(void)selectRowInTableView:(UITableView *)tableView whichContainsPurchase:(Purchase *)purchase
{
    NSString *key = purchase.datetime;
    NSInteger section = [keys_ indexOfObject:key];
    NSInteger row = [items_[key] indexOfObject:purchase];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (NSString*) makeHTMLTextForAirPrint
{
    NSString* strHtmlText = @"";
    Client* client = [[ModelManager shared] clientByID:self.selectedPurchase.clientID];
    Company* company = [[ModelManager shared] fetchCompany];
    //Company Name
    //str_CompanyAddress
    //str_Date
    //str_City, str_ZipCode
    //str_Purchase
    //str_Name
    //str_StreetAddress
    //str_City, str_ZipCode
    //str_PhoneNumber
    //str_Email
    strHtmlText = [NSString stringWithFormat:@"<!doctype html>\
   <html>\
   <head>\
       <meta charset=\"UTF-8\">\
       <title>SALES INVOICE</title>\
   </head>\
   \
   <body>\
       <table width=\"736\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\
       <tbody>\
           <tr>\
               <td height=\"96\" colspan=\"6\" align=\"center\" valign=\"middle\" bgcolor=\"#989898\"><!--br {mso-data-placement:same-cell;}--><h1 style=\"color: #FFFFFF\">%@</h1></td>\
           </tr>\
           <tr>\
               <td height=\"24\" colspan=\"6\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"25\" colspan=\"3\"><!--br {mso-data-placement:same-cell;}-->%@</td>\
               <td colspan=\"3\" bgcolor=\"#EFEFEF\"><!--br {mso-data-placement:same-cell;}--><strong>DATE: %@</strong></td>\
           </tr>\
           <tr>\
               <td height=\"26\" colspan=\"3\"><!--br {mso-data-placement:same-cell;}-->%@, %@</td>\
               <td colspan=\"3\" bgcolor=\"#EFEFEF\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"26\" colspan=\"3\">&nbsp;</td>\
               <td colspan=\"3\" bgcolor=\"#EFEFEF\"><!--br {mso-data-placement:same-cell;}--><strong>PURCHASE # %@</strong></td>\
           </tr>\
           <tr>\
               <td height=\"32\" colspan=\"6\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td width=\"143\" height=\"23\" bgcolor=\"#EFEFEF\"><!--br {mso-data-placement:same-cell;}-->Client</td>\
               <td width=\"133\">&nbsp;</td>\
               <td width=\"106\">&nbsp;</td>\
               <td width=\"109\">&nbsp;</td>\
               <td width=\"118\">&nbsp;</td>\
               <td width=\"127\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"26\">&nbsp;</td>\
               <td colspan=\"5\" style=\"font-size: 12px\"><!--br {mso-data-placement:same-cell;}-->%@</td>\
           </tr>\
           <tr>\
               <td height=\"25\">&nbsp;</td>\
               <td colspan=\"5\" style=\"font-size: 12px\"><!--br {mso-data-placement:same-cell;}-->%@</td>\
           </tr>\
           <tr>\
               <td height=\"24\">&nbsp;</td>\
               <td colspan=\"5\" style=\"font-size: 12px\"><!--br {mso-data-placement:same-cell;}-->%@, %@, %@</td>\
           </tr>\
           <tr>\
               <td height=\"24\">&nbsp;</td>\
               <td colspan=\"5\" style=\"font-size: 12px\"><!--br {mso-data-placement:same-cell;}-->%@</td>\
           </tr>\
           <tr>\
               <td height=\"26\">&nbsp;</td>\
               <td colspan=\"5\" style=\"font-size: 12px\"><!--br {mso-data-placement:same-cell;}-->%@</td>\
           </tr>\
           <tr>\
               <td height=\"33\" colspan=\"6\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"25\" colspan=\"6\" bgcolor=\"#DCDCDC\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"25\" colspan=\"6\" bgcolor=\"#EFEFEF\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"25\" colspan=\"6\" bgcolor=\"#FFFFFF\">&nbsp;</td>\
           </tr>\
           <tr>\
               <td height=\"31\" colspan=\"5\" align=\"center\" valign=\"middle\" bgcolor=\"#666666\" style=\"color: #FFFFFF\"><strong>DESCRIPTION</strong></td>\
               <td align=\"right\" valign=\"middle\" bgcolor=\"#989898\" style=\"color: #FFFFFF\"><strong>AMOUNT</strong></td>\
           </tr>", 
                   company.name, 
                   company.street, 
                   self.selectedPurchase.datetime, 
                   company.city,
                   company.state,
                   company.zip, 
                   self.selectedPurchase.number, 
                   client.name, 
                   client.street, 
                   client.city, 
                   client.zip, 
                   client.phone, 
                   client.email];
    
    //str_MetalName
    //str_Unit
    for (int i = 0; i < self.selectedPurchase.items.count; i ++)
    {
        strHtmlText = [strHtmlText stringByAppendingString:[NSString stringWithFormat:@"<tr>\
                                                            <td height=\"28\">&nbsp;</td>\
                                                            <td colspan=\"4\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f %@ %@ %@</td>\
                                                            <td align=\"right\" valign=\"middle\" bgcolor=\"#F3F3F3\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f</td>\
                                                            </tr>",
                                                            ((PurchaseItem*)self.selectedPurchase.items[i]).weight, 
                                                            ((PurchaseItem*)self.selectedPurchase.items[i]).unit.shortName.uppercaseString, 
                                                            ((PurchaseItem*)self.selectedPurchase.items[i]).purityName, 
                                                            ((PurchaseItem*)self.selectedPurchase.items[i]).metal.name.uppercaseString, 
                                                            ((PurchaseItem*)self.selectedPurchase.items[i]).price]
                       ];
    }
    
    //    <tr>
    //    <td height="26">&nbsp;</td>
    //    <td colspan="4">&nbsp;</td>
    //    <td align="right" valign="middle" bgcolor="#F3F3F3" style="font-size: 14px"><!--br {mso-data-placement:same-cell;}-->
    //    str_subTotal</td>
    //    </tr>
    //    <tr>
    //    <td height="18">&nbsp;</td>
    //    <td colspan="4">&nbsp;</td>
    //    <td align="right" valign="middle" bgcolor="#F3F3F3" style="font-size: 14px">&nbsp;</td>
    //    </tr>
    //    <tr>
    //    <td height="26">&nbsp;</td>
    //    <td colspan="4">&nbsp;</td>
    //    <td align="right" valign="middle" bgcolor="#F3F3F3" style="font-size: 14px"><!--br {mso-data-placement:same-cell;}-->
    //    str_Fee</td>
    //    </tr>
    strHtmlText = [strHtmlText stringByAppendingString:[NSString stringWithFormat:@"\
                        <tr>\
                            <td align=\"center\" height=\"30\" valign=\"middle\" colspan=\"4\" bgcolor=\"#666666\" style=\"color: #FFFFFF\">&nbsp; </td>\
                            <td align=\"center\" height=\"30\" valign=\"middle\" colspan=\"1\" bgcolor=\"#666666\" style=\"color: #FFFFFF\"> TOTAL&nbsp;</td>\
                            <td align=\"right\" height=\"30\" valign=\"middle\" bgcolor=\"#989898\">%f&nbsp; </td>\
                        </tr>\
                        <tr>\
                            <td height=\"25\" colspan=\"6\" bgcolor=\"#FFFFFF\">&nbsp;</td>\
                        </tr>\
                        <tr>\
                            <td height=\"25\" colspan=\"6\" bgcolor=\"#FFFFFF\">&nbsp;</td>\
                        </tr>\
                        <tr>\
                            <td height=\"25\" colspan=\"6\" bgcolor=\"#FFFFFF\">&nbsp;</td>\
                        </tr>\
                    </tbody>\
                </table>\
            </body>\
            </html>",

                                                        self.selectedPurchase.price]];
    
    return strHtmlText;
}
//*/

@end
