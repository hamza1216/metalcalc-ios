//
//  MCDetailedPurchaseViewController.m
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import "MCDetailedPurchaseViewController.h"
#import "MCClientsViewController.h"
#import "MCNewClientViewController.h"
#import "ModelManager.h"


@interface MCDetailedPurchaseViewController ()

@end


@implementation MCDetailedPurchaseViewController

@synthesize clientLabel;
@synthesize purchaseView;
@synthesize clientView;
@synthesize purchase;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBackButton];
    
    [self initPrintButton];
    [purchaseView setHeaderHeight:60];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self.navigationItem setTitle:purchase.number];
    
    if ([self.purchase.clientID integerValue] < 1) {
        clientLabel.text = @"";
    }
    else {
        clientLabel.text = [[ModelManager shared] clientNameByID:purchase.clientID];
    }
    
    [purchaseView setupWithPurchase:purchase];
}

- (IBAction)addClient:(id)sender
{    
    MCNewClientViewController *vc = [MCNewClientViewController new];
    vc.associatePurchase = self.purchase;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)selectClient:(id)sender
{
    MCClientsViewController *vc = [MCClientsViewController new];
    vc.associatePurchase = self.purchase;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Sample";
    pic.printInfo = printInfo;
    
    NSString *htmlString = [self makeHTMLTextForAirPrint];
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlString];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(30.0, 30.0, 30.0, 30.0);
    htmlFormatter.maximumContentWidth = 7 * 72.0;   // printed content should be 6-inches wide within those margins
    htmlFormatter.maximumContentHeight = htmlFormatter.maximumContentWidth * 1.5f;
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
//        [pic presentFromBarButtonItem:self.myPrintBarButton animated:YES completionHandler:completionHandler];      
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
        strHtmlText = [strHtmlText stringByAppendingString:[NSString stringWithFormat:@"\
        <tr>\
            <td height=\"28\">&nbsp;</td>\
            <td colspan=\"4\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f %@ %@ %@</td>\
            <td align=\"right\" valign=\"middle\" bgcolor=\"#F3F3F3\" style=\"font-size: 14px\"><!--br {mso-data-placement:same-cell;}-->%f</td>\
        </tr>", 
                                                            ((PurchaseItem*)purchase.items[i]).weight, 
                                                            ((PurchaseItem*)purchase.items[i]).unit.shortName.uppercaseString, 
                                                            ((PurchaseItem*)purchase.items[i]).purityName, 
                                                            ((PurchaseItem*)purchase.items[i]).metal.name.uppercaseString, 
                                                            ((PurchaseItem*)purchase.items[i]).price]
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
