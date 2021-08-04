//
//  MCClientsListViewController_iPad.m
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCClientsListViewController_iPad.h"
#import "MCClientCell_iPad.h"
#import "MCClientDetailsViewController_iPad.h"
#import "MCBaseDetailViewController_iPad.h"
#import "MCClientEditViewController_iPad.h"
#define TABLE_Y_PORTRAIT    111.0
#define TABLE_Y_LANDSCAPE   48.0
#define HEADER_WIDTH_FULL   669.0
#define HEADER_WIDTH_SHORT  309.0
#define HEADER_HEIGHT       45.0
#define HEADER_FRAME_FULL   CGRectMake(0,0,HEADER_WIDTH_FULL,HEADER_HEIGHT)
#define HEADER_FRAME_SHORT  CGRectMake(0,0,HEADER_WIDTH_SHORT,HEADER_HEIGHT)

@interface MCClientsListViewController_iPad () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *items_;
    NSMutableArray *keys_;
    Client *selectedClient_;
    BOOL isNewClient_;
    BOOL isClientEditingOrAdding_;
    MCClientDetailsViewController_iPad *clientDetailsVC_;
    MCClientEditViewController_iPad *clientEditVC_;
    BOOL needToHideLabelAddClient_;
}
@property (nonatomic, copy) NSString *selectedClientID;

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIButton *addNewClientButton;
@property (nonatomic, retain) IBOutlet UILabel *addClientLabel;

- (void)setupClients;

- (IBAction)addClientAction:(id)sender;


@end

@implementation MCClientsListViewController_iPad

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
    items_ = [NSMutableDictionary new];
    keys_ = [NSMutableArray new];
    [self.splitViewController popToMasterAnimated:YES];
}

- (void)viewDidUnload
{
    [items_ release];
    [keys_ release];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRightToolBarButtonHidden:YES];
    [self setupClients];
    [[self table] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

-(void)addClientAction:(id)sender
{
    [self actionForLeftButtonOnTheToolBar];
}

- (void)setupClients
{
    [items_ removeAllObjects];
    [keys_ removeAllObjects];
    
    for (Client *client in [[ModelManager shared] clients]) {
        NSString *key = [[client.name substringToIndex:1] capitalizedString];
        if (items_[key] == nil) {
            items_[key] = [NSMutableArray array];
            [keys_ addObject:key];
        }
        [items_[key] addObject:client];
    }
    
    for (NSString *key in keys_) {
        items_[key] = [items_[key] sortedArrayUsingSelector:@selector(compare:)];
    }
    
    NSArray *arr = [keys_ sortedArrayUsingSelector:@selector(compare:)];
    [keys_ release];
    keys_ = [[NSMutableArray alloc] initWithArray:arr];
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
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    UIImageView *headerBg = [[UIImageView alloc] initWithFrame:frame];
    headerBg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) || self.associatePurchase)
    {
        headerBg.image = [UIImage imageNamed:@"content_textheader_back"];
    }
    else
    {
        headerBg.image = [UIImage imageNamed:@"content_textheader_back_short"];       
    }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 2, 41.0, 41.0)];
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
    static NSString *cellID = @"ClientCell";
    MCClientCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[MCClientCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    Client *client = items_[keys_[indexPath.section]][indexPath.row];
    [cell updateClientCell:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)||self.associatePurchase];
    if (client != nil) {
        //cell.icon = client.icon;
        cell.name = client.name;
        if (client.icon != nil) {
            cell.icon = client.icon;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CLIENT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) || self.associatePurchase)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Client *client = items_[keys_[indexPath.section]][indexPath.row];
    if (self.associatePurchase) {
        self.selectedClientID = client.clientID;
        
        if (self.associatePurchase.clientID.integerValue > 0) {
            if ([self.associatePurchase.clientID isEqualToString:client.clientID]) {
                [self showAlertWithTitle:@"" andMessage:@"The purchase is already associated with this Client"];
            }
            else {
                [self showAlertWithTitle:@"" andMessage:@"The purchase is associated with another Client. Would you like to associate it with this Client instead?" okTitle:@"Yes" cancelTitle:@"Cancel" delegate:self];
            }
        }
        else {
            [self associateClientAndPop];
        }
    }
    else if (self.selectClient) {
        [[ModelManager shared] setShouldSavePurchase:YES];
        Purchase *purchase = [[ModelManager shared] activePurchase];
        purchase.clientID = client.clientID;
        [[ModelManager shared] approvePurchase];
        [self.navigationViewController popViewControllerAnimated:YES];
    }
    else {        
        [[self delegate] didChooseClient:client];
        selectedClient_ = client;
        [self.splitViewController pushDetailAnimated:YES];
    }
}

- (void)associateClientAndPop
{
    self.associatePurchase.clientID = self.selectedClientID;
    [[ModelManager shared] updatePurchaseWithNewClient:self.associatePurchase];
    [self.navigationViewController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [self associateClientAndPop];
    }
}

-(void)selectRowInTableView:(UITableView *)tableView whichContainsClient:(Client *)client
{
    NSString *key = [[client.name substringToIndex:1] capitalizedString];
    NSInteger section = [keys_ indexOfObject:key];
    NSInteger row = [items_[key] indexOfObject:client];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - Memory management

- (void)dealloc
{
    [self setSelectedClientID:nil];
    [self setTable:nil];
    [super dealloc];
}


#pragma mark - MCClientDetailsViewController delegate methods

- (void)setAddPurchaseButtonHidden:(BOOL)hidden
{
    needToHideLabelAddClient_ = hidden;
    [self setLeftToolBarButtonHidden:hidden];
    [self.addClientLabel setHidden:hidden];
}

- (void)willEditClient:(Client *)client
{
    isClientEditingOrAdding_ = YES;
    
}

-(void)didCancel
{
    isClientEditingOrAdding_ = NO;
}

-(void)clientDetailsDidUpdate:(Client *)client
{
    [self setupClients];
    [[self table] reloadData];
    selectedClient_ = client;
    [self selectRowInTableView:self.table whichContainsClient:client];
    isClientEditingOrAdding_ = NO;
}

- (void)newClientWasAdded:(Client *)client
{
    [self setupClients];
    [[self table] reloadData];
    selectedClient_ = client;
    [self selectRowInTableView:self.table whichContainsClient:client];
    isClientEditingOrAdding_ = NO;    
}

#pragma mark - Left Toolbar button

-(void)actionForLeftButtonOnTheToolBar
{
    if(self.associatePurchase || self.selectClient)
    {
        MCClientEditViewController_iPad *newClientVC = [MCClientEditViewController_iPad new];
        newClientVC.isNewClient = YES;
        newClientVC.associatePurchase = self.associatePurchase;
        newClientVC.selectClient = self.selectClient;
        newClientVC.delegate = self;
        [[self navigationViewController] pushViewController:newClientVC animated:YES];
    }
    else
    {
        selectedClient_ = nil;
        [[self table] deselectRowAtIndexPath:[[self table] indexPathForSelectedRow] animated:YES];
        [self.splitViewController pushDetailAnimated:YES];
        [[self delegate] addNewClient];        
    }
}

- (UIImage *)imageForLeftToolBarButton
{
    return [UIImage imageNamed:@"btn_add_norm"];
}

- (CGRect)imageRectForLefToolBarButton
{
    return CGRectMake(12.0f, 15.0f, [[self imageForLeftToolBarButton] size].width, [[self imageForLeftToolBarButton] size].height);
}


#pragma mark - Setup for Interface Orientation

- (void)setupForLandscape
{    
    [super setupForLandscape];    
    if(self.associatePurchase||self.selectClient)
    {
        [self setLeftToolBarButtonHidden:YES];
        self.table.frame = CLIENT_TABLE_FRAME_LANDSCAPE_WITH_BACK;
        [[self addNewClientButton] setHidden:NO];
        [self.addClientLabel setHidden:YES];
        self.needsMoveBackButtonToTheContainer = YES;
        [self addBackButton];
    }
    else
    {
        if(!isClientEditingOrAdding_ && !needToHideLabelAddClient_)
        {
            [self setLeftToolBarButtonHidden:NO];
            [self.addClientLabel setHidden:NO];
        }
        else
        {
            [self setLeftToolBarButtonHidden:YES];
            [self.addClientLabel setHidden:YES];
        }
        self.table.frame = CLIENT_TABLE_FRAME_LANDSCAPE;
        [[self addNewClientButton] setHidden:YES];
        
        [self removeBackButton];
    }    
    [[self table] reloadData];
    if(selectedClient_)
    {
        [self selectRowInTableView:[self table] whichContainsClient:selectedClient_];
    }
}

- (void)setupForPortrait
{
    [self setLeftToolBarButtonHidden:YES];
    [super setupForPortrait];
    if(self.associatePurchase || self.selectClient)
    {
        self.needsMoveBackButtonToTheContainer = YES;
        [self addBackButton];
    }
    else
    {
        [self removeBackButton];
    }
    [[self addClientLabel] setHidden:YES];    
    [[self addNewClientButton] setHidden:NO];
    self.table.frame = CLIENT_TABLE_FRAME_PORTRAIT;
    [[self table] reloadData];
}

@end
