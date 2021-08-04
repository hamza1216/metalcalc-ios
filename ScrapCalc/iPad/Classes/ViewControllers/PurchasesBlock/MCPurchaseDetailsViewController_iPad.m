//
//  MCPurchaseDetailsViewController.m
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCPurchaseDetailsViewController_iPad.h"
#import "MCPurchaseView_iPad.h"
#import "ModelManager.h"
#import "MCPurchaseListViewController_iPad.h"
#import "MCClientsListViewController_iPad.h"
#import "MCClientEditViewController_iPad.h"

#define CONTAINER_VIEW_Y_PORTRAIT 80.0

@interface MCPurchaseDetailsViewController_iPad ()

@property (nonatomic, retain) IBOutlet UIView *purchaseContentView;

@property (nonatomic, retain) IBOutlet UILabel *purchaseNameLabel;

@property (nonatomic, retain) IBOutlet UIView *noSelectedPurchaseView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* m_barBtnPrint;

- (IBAction)addPurchase:(id)sender;

@end

@implementation MCPurchaseDetailsViewController_iPad

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
    // Do any additional setup after loading the view from its nib.
    
    CGRect frame = self.noSelectedPurchaseView.frame;
    frame.origin.x = self.view.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = self.view.frame.size.height/2 - frame.size.height/2 - 200.0;
    self.noSelectedPurchaseView.frame = frame;
    [[self view] addSubview:self.noSelectedPurchaseView];
    [self.noSelectedPurchaseView setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.purchase)
    {
        [[self containerView] setHidden:YES];
        [[self noSelectedPurchaseView] setHidden:NO];
        [[self splitViewController] popToMasterAnimated:NO];
    }
    else
    {
        [self purchaseListDidSelectPurchase:self.purchase];
    }
    [[self delegate] setAddPurchaseButtonHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)addPurchase:(id)sender
{
    [[[self splitViewController] toolbar] selectTabIndex:0];
}

- (IBAction)addClient:(id)sender
{
    MCClientEditViewController_iPad *vc = [MCClientEditViewController_iPad new];
    vc.associatePurchase = self.purchase;
    vc.isNewClient = YES;
    
    [self.navigationViewController pushViewController:vc animated:YES];
    [[self delegate] setAddPurchaseButtonHidden:YES];
    [vc release];
}

- (IBAction)selectClient:(id)sender
{
    MCClientsListViewController_iPad *vc = [MCClientsListViewController_iPad new];
    vc.associatePurchase = self.purchase;
    
    [[self delegate] setAddPurchaseButtonHidden:YES];
    [self.navigationViewController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - MCPurchaseListViewControllerDelegate methods

-(void)purchaseListDidSelectPurchase:(Purchase *)purchase
{
    self.purchase = purchase;
    [self.containerView setHidden:NO];
    [[self noSelectedPurchaseView] setHidden:YES];
    [[self purchaseView] setHeaderHeight:115.0];
    if ([self.purchase.clientID integerValue] < 1) {
        self.clientLabel.text = @"";
    }
    else {
        self.clientLabel.text = [[ModelManager shared] clientNameByID:self.purchase.clientID];
    }
    [self.purchaseNameLabel setText:self.purchase.number];
    [self.purchaseView setupWithPurchase:self.purchase];
}


#pragma mark - Setup for Interface Orientation

-(void)setupForLandscape
{
    [super setupForLandscape];
    if(!self.purchase)
    {
        [self.containerView setHidden:YES];
        [self.noSelectedPurchaseView setHidden:NO];
    }
    [self removeBackButton];
    [self removePrintButton];
}

-(void)setupForPortrait
{
    [super setupForPortrait];
    if(!self.purchase)
    {
        if(UIInterfaceOrientationIsPortrait( [[UIApplication sharedApplication] statusBarOrientation]))
        {
            [self.splitViewController popToMasterAnimated:YES];
        }
        else
        {
            [self removeBackButton];
            [self removePrintButton];
            [[self noSelectedPurchaseView] setHidden:NO];
        }
    }
    self.needsMoveBackButtonToTheContainer = NO;
    [self addBackButton];
    
    self.needsMovePrintButtonToTheContainer = NO;
    [self addPrintButton];
}

- (void)onClickBtnPrint:(UIButton *)sender
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    if(!pic)
    {
        NSLog(@"Couldn't get shared UIPrintInteractionController, need iOS 4.2 or up!");
        return;
    }
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOrientationLandscape;
    printInfo.jobName = @"Sample";
    

    NSString *htmlString = [self makeHTMLTextForAirPrint];
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlString];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(30.0, 30.0, 30.0, 30.0);
    htmlFormatter.maximumContentWidth = 7 * 72.0;   // printed content should be 6-inches wide within those margins
//    htmlFormatter.maximumContentHeight = htmlFormatter.maximumContentWidth * 1.5f;
    pic.printFormatter = htmlFormatter;
    
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
        [pic presentFromRect:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/2, self.view.frame.size.width/2, self.view.frame.size.height) inView:self.view animated:true completionHandler:completionHandler];
//        [pic presentFromBarButtonItem:nil animated:YES completionHandler:completionHandler];
    } 
    else
    {
        [pic presentAnimated:YES completionHandler:completionHandler];
    }

}

- (NSString*) makeHTMLTextForAirPrint
{
    NSString* strHtmlText = @"";
    Client* client = [[ModelManager shared] clientByID:self.purchase.clientID];
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
                   self.purchase.datetime, 
                   company.city,
                   company.state, 
                   company.zip, 
                   self.purchase.number, 
                   client.name, 
                   client.street, 
                   client.city, 
                   client.zip, 
                   client.phone, 
                   client.email];
    
    //str_MetalName
    //str_Unit
    for (int i = 0; i < self.purchase.items.count; i ++)
    {
        strHtmlText = [strHtmlText stringByAppendingString:[NSString stringWithFormat:@"<tr>\
                                                            <td height=\"28\">&nbsp;</td>\
                                                            <td colspan=\"4\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f %@ %@ %@</td>\
                                                            <td align=\"right\" valign=\"middle\" bgcolor=\"#F3F3F3\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f</td>\
                                                            </tr>", 
                                                            ((PurchaseItem*)self.purchase.items[i]).weight, 
                                                            ((PurchaseItem*)self.purchase.items[i]).unit.shortName.uppercaseString, 
                                                            ((PurchaseItem*)self.purchase.items[i]).purityName, 
                                                            ((PurchaseItem*)self.purchase.items[i]).metal.name.uppercaseString, 
                                                            ((PurchaseItem*)self.purchase.items[i]).price]
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
                                                        
                                                        self.purchase.price]];    
    
    return strHtmlText;
}
//*/

@end
