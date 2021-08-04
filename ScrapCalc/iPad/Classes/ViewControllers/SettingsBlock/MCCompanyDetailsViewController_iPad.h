//
//  MCCompanyDetailsViewController_iPad.h
//  ScrapCalc
//
//  Created by jhpassion on 7/5/14.
//
//

#import "MCSettingsViewController_iPad.h"

@interface MCCompanyDetailsViewController_iPad : MCSettingsViewController_iPad

@property (retain, nonatomic) IBOutlet UIScrollView *m_sclMain;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyName;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyCountry;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyState;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyCity;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyStreet;
@property (retain, nonatomic) IBOutlet UITextField *m_txtCompanyZip;
@property (nonatomic, retain) Company       *company;

@end
