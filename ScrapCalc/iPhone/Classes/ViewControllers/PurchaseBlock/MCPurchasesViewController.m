//
//  MCPurchasesViewController.m
//  ScrapCalc
//
//  Created by word on 18.03.13.
//
//

#import "MCPurchasesViewController.h"
#import "MCDetailedPurchaseViewController.h"
#import "PurchasesCell.h"
#import "ModelManager.h"
#import "CkoCsv.h"

@interface MCPurchasesViewController ()

@property (nonatomic, retain) Purchase *selectedPurchase;

@end

@implementation MCPurchasesViewController

@synthesize associateClient;
@synthesize selectedPurchase;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"PURCHASES"];
    
    table_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    table_.backgroundColor = [UIColor clearColor];
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.dataSource = self;
    table_.delegate = self;
    [self.view addSubview:table_];
    
    items_ = [NSMutableDictionary new];
    keys_ = [NSMutableArray new];
    
    if (nil == self.associateClient) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [[btn.widthAnchor constraintEqualToConstant:40] setActive:YES];
        [[btn.heightAnchor constraintEqualToConstant:32] setActive:YES];
        [btn setBackgroundImage:[UIImage imageNamed:@"purchase_add.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addNewPurchase:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        UIButton *btnExportCSV = [UIButton buttonWithType:UIButtonTypeCustom];
        [[btnExportCSV.widthAnchor constraintEqualToConstant:40] setActive:YES];
        [[btnExportCSV.heightAnchor constraintEqualToConstant:32] setActive:YES];
        [btnExportCSV setBackgroundImage:[UIImage imageNamed:@"purchase_export_csv.png"] forState:UIControlStateNormal];
        [btnExportCSV addTarget:self action:@selector(onClickBtnExportCSV:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExportCSV];
    }
}

- (void)viewDidUnload
{
    [items_ release];
    [keys_ release];
    [self setSelectedPurchase:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupPurchases];
    [table_ reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setScreenName:PURCHASES_SCREEN_NAME];
}

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

#pragma mark - Private

- (void)addNewPurchase:(UIButton *)sender
{
    self.tabBarController.selectedIndex = 1;
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
    [csv SetColumnName:[NSNumber numberWithInt:0] columnName:@"ClientName"];
    [csv SetColumnName:[NSNumber numberWithInt:1] columnName:@"PurchaseNumber"];
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

- (void)onClickBtnExportCSV:(UIButton *)sender
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
            txtEmailResult = @"Mail cancelled";
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            txtEmailResult = @"Mail saved";
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PurchasesCell";
    PurchasesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[PurchasesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    Purchase *purchase = items_[keys_[indexPath.section]][indexPath.row];
    cell.number = purchase.number;
    cell.client = [[ModelManager shared] clientNameByID:purchase.clientID];
    
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
        MCDetailedPurchaseViewController *vc = [MCDetailedPurchaseViewController new];
        vc.purchase = items_[keys_[indexPath.section]][indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

- (void)associatePurchaseAndPop
{
    self.selectedPurchase.clientID = self.associateClient.clientID;
    [[ModelManager shared] updatePurchaseWithNewClient:self.selectedPurchase];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [self associatePurchaseAndPop];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    [table_ release];
    [super dealloc];
}

@end
