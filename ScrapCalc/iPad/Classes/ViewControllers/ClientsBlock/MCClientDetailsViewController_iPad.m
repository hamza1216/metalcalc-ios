//
//  MCClientDetailsViewController_iPad.m
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCClientDetailsViewController_iPad.h"
#import "Client.h"
#import "ModelManager.h"
#import "MCClientEditViewController_iPad.h"
#import "MCPurchaseListViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "MCPurchaseDetailsViewController_iPad.h"


#define CONTAINER_VIEW_Y_PORTRAIT 80.0

@interface MCClientDetailsViewController_iPad () <UITextFieldDelegate, UIImagePickerControllerDelegate>
{
    BOOL isNewClientWasSelected_;
}

@property (nonatomic, retain) IBOutlet UIView *noSelectedClientView;

-(IBAction)editAction:(id)sender;
- (IBAction)addClientAction:(id)sender;

@end

@implementation MCClientDetailsViewController_iPad

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
    purchases_ = [NSMutableArray new];
    self.table1.layer.cornerRadius = 2;
    
    CGRect frame = self.noSelectedClientView.frame;
    frame.origin.x = self.view.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = self.view.frame.size.height/2 - frame.size.height/2 - 200.0;
    self.noSelectedClientView.frame = frame;
    [[self view] addSubview:self.noSelectedClientView];
    [self.noSelectedClientView setHidden:YES];
	// Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.client)
    {
        [self didChooseClient:self.client];
    }
    else
    {
        [[self containerView] setHidden:YES];
        [[self noSelectedClientView] setHidden:NO];
        [[self splitViewController] popToMasterAnimated:NO];
    }
    if(isNewClientWasSelected_)
    {
        [self setupForClient];
        [[self delegate] clientDetailsDidUpdate:self.client];
        isNewClientWasSelected_ = NO;
    }
    [[self delegate] setAddPurchaseButtonHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MCClientsListViewControllerDelegate methods

-(void)didCancel
{
    [[self delegate] didCancel];
}

-(void)didChooseClient:(Client *)client
{
    [[self containerView] setHidden:NO];
    [[self noSelectedClientView] setHidden:YES];
    [self setClient:client];
    [self setupForClient];
    [[self table1] reloadData];
}

-(void)addNewClient
{
    [[self noSelectedClientView] setHidden:YES];
    MCClientEditViewController_iPad *newClientVC = [MCClientEditViewController_iPad new];
    [self setClient:nil];
    newClientVC.delegate = self;
    [newClientVC setIsNewClient:YES];
    isNewClientWasSelected_ = YES;
    [[self delegate] willEditClient:self.client];
    [[self navigationViewController] pushViewController:newClientVC animated:!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)];
}


#pragma mark - actions

- (IBAction)associatePurchase:(id)sender
{
    MCPurchaseListViewController_iPad *vc = [MCPurchaseListViewController_iPad new];
    vc.associateClient = self.client;
    [[self delegate] setAddPurchaseButtonHidden:YES];
    [self.navigationViewController pushViewController:vc animated:YES];
    [vc release];
}


-(void)editAction:(id)sender
{    
    MCClientEditViewController_iPad *editVC = [MCClientEditViewController_iPad new];
    [editVC setIsNewClient:NO];
    editVC.delegate = self;
    [editVC setClient:self.client];
    [[self delegate] willEditClient:self.client];
    [[self navigationViewController] pushViewController:editVC animated:YES];
}

-(void)addClientAction:(id)sender
{
    [self addNewClient];
}



#pragma mark - private methods

- (void)setupForClient
{
    if (self.client.clientID.integerValue > 0) {
        self.associateButton.hidden = self.associateLabel.hidden = NO;
    }
    else {
        self.associateButton.hidden = self.associateLabel.hidden = YES;
    }
    
    [purchases_ removeAllObjects];
    [purchases_ addObjectsFromArray:[[ModelManager shared] purchasesForClient:self.client]];
    
    [self.fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", self.client.firstname.length?self.client.firstname:@"", self.client.lastname.length?self.client.lastname:@""]];
    [self textFieldForTag:ClientButtonTagFirstname].text = self.client.firstname;
    [self textFieldForTag:ClientButtonTagLastname].text = self.client.lastname;
    [self textFieldForTag:ClientButtonTagPhone].text = self.client.phone;
    [self textFieldForTag:ClientButtonTagEmail].text = self.client.email;
    [self textFieldForTag:ClientButtonTagStreet].text = self.client.street;
    [self textFieldForTag:ClientButtonTagCity].text = self.client.city;
    [self textFieldForTag:ClientButtonTagState].text = self.client.state;
    [self textFieldForTag:ClientButtonTagZip].text = self.client.zip;
    
    if (self.client.icon == nil) {
        self.clientDetailsPhotoView.image = [UIImage imageNamed:@"nophoto_big"];
    }
    else {
        self.clientDetailsPhotoView.image = self.client.icon;
    }
    [self resizeClientDetailScroll];
}

- (UITextField *)textFieldForTag:(NSInteger)tag
{
    return (UITextField *)[self.containerView viewWithTag:tag];
}

- (void)resizeClientDetailScroll
{
    self.table1.frame = CGRectMake(self.table1.frame.origin.x, self.table1.frame.origin.y, self.table1.frame.size.width, purchases_.count * NEWCLIENT_CELL_HEIGHT);
    self.scrollDetailsView.contentSize = CGSizeMake(self.scrollDetailsView.frame.size.width, MAX(460.0, self.table1.frame.origin.y + self.table1.frame.size.height + 10));
}


#pragma mark - UITableView methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return purchases_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"NewClientPurchasesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_arrow_norm"]] autorelease];
    }
    cell.textLabel.text = [purchases_[indexPath.row] number];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MCPurchaseDetailsViewController_iPad *vc = [MCPurchaseDetailsViewController_iPad new];
    vc.purchase = purchases_[indexPath.row];
    [self.navigationViewController pushViewController:vc animated:YES];
    [vc release];
}


#pragma mark - MCClientDetailsViewController delegate methods

-(void)clientDetailsDidUpdate:(Client *)client
{
    self.client = client;
    [self setupForClient];
    [[self delegate] clientDetailsDidUpdate:client];
}

- (void)newClientWasAdded:(Client *)client
{
    [self setClient:client];
    [self setupForClient];
    [[self delegate] newClientWasAdded:client];
}

#pragma mark - Setup for Interface Orientation

-(void)setupForLandscape
{   
    [super setupForLandscape];
    if(!self.client)
    {
        [self.containerView setHidden:YES];
        [self.noSelectedClientView setHidden:NO];
    }
    [self removeBackButton];
    [self resizeClientDetailScroll];
}

-(void)setupForPortrait
{
    [super setupForPortrait];    
    if(!self.client)
    {
        if(UIInterfaceOrientationIsPortrait( [[UIApplication sharedApplication] statusBarOrientation]))
        {
            [self.splitViewController popToMasterAnimated:isNewClientWasSelected_];
        }
        else
        {
            [self removeBackButton];
            [[self noSelectedClientView] setHidden:NO];
        }
    }
    [self setNeedsMoveBackButtonToTheContainer:NO];
    [self addBackButton];
    [self resizeClientDetailScroll];
}

-(void)backAction:(id)sender
{
    [super backAction:sender];
    self.client = nil;
    [[self delegate] clientDetailsDidUpdate:nil];
}

@end
