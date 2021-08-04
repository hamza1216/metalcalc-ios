//
//  MCClientsViewController.m
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "MCClientsViewController.h"
#import "MCNewClientViewController.h"
#import "ClientsCell.h"
#import "ModelManager.h"

@interface MCClientsViewController ()

@property (nonatomic, copy) NSString *selectedClientID;

@end

@implementation MCClientsViewController

@synthesize selectClient;
@synthesize selectedClientID;
@synthesize associatePurchase;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.navigationController.navigationBar.hidden = NO;
    
    if (self.associatePurchase) {
        [self.navigationItem setTitle:self.associatePurchase.number];
    }

    table_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    table_.backgroundColor = [UIColor clearColor];
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.dataSource = self;
    table_.delegate = self;
    [self.view addSubview:table_];
    
    items_ = [NSMutableDictionary new];
    keys_ = [NSMutableArray new];
    
//    if (/*self.associatePurchase == nil && */!self.selectClient) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [[btn.widthAnchor constraintEqualToConstant:32] setActive:YES];
    [[btn.heightAnchor constraintEqualToConstant:26] setActive:YES];
        [btn setBackgroundImage:[UIImage imageNamed:@"purchase_add.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addNewClient:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
//    }

    [table_ reloadData];
}

- (void)viewDidUnload
{
    [items_ release];
    [keys_ release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupClients];
    [table_ reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [self setScreenName:CLIENTS_SCREEN_NAME];
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

#pragma mark - Private

- (void)addNewClient:(UIButton *)sender
{
    MCNewClientViewController *vc = [MCNewClientViewController new];
    vc.selectClient = self.selectClient;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
    static NSString *cellID = @"ClientCell";
    ClientsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[ClientsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    Client *client = items_[keys_[indexPath.section]][indexPath.row];
    [cell setDefaultIcon];
    if (client != nil) {
        //cell.icon = client.icon;
        cell.name = client.name;
        if (client.icon != nil) {
            cell.icon = client.icon;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        MCNewClientViewController *vc = [MCNewClientViewController new];
        vc.client = client;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

- (void)associateClientAndPop
{
    self.associatePurchase.clientID = self.selectedClientID;
    [[ModelManager shared] updatePurchaseWithNewClient:self.associatePurchase];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        [self associateClientAndPop];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    [self setSelectedClientID:nil];
    [table_ release];
    [super dealloc];
}

@end
