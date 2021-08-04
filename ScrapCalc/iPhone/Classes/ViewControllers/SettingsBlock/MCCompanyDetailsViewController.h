//
//  MCCompanyDetailsViewController.h
//  ScrapCalc
//
//  Created by jhpassion on 7/5/14.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Company.h"

@interface MCCompanyDetailsViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyName;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyCountry;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyState;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyCity;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyStreet;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyZip;
@property (nonatomic, retain) Company       *company;

- (IBAction)onClickBtnSave:(id)sender;
@end
