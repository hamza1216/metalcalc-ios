//
//  MCCompanyDetailsViewController.m
//  ScrapCalc
//
//  Created by jhpassion on 7/5/14.
//
//

#import "MCCompanyDetailsViewController.h"

@interface MCCompanyDetailsViewController ()

@end

@implementation MCCompanyDetailsViewController

@synthesize company;
@synthesize m_txtCompanyCity;
@synthesize m_txtCompanyCountry;
@synthesize m_txtCompanyName;
@synthesize m_txtCompanyState;
@synthesize m_txtCompanyStreet;
@synthesize m_txtCompanyZip;

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
    
    self.navigationItem.title = @"COMPANY INFO";
    
    company = [[ModelManager shared] fetchCompany];
    
    m_txtCompanyName.text = company.name;
    m_txtCompanyCountry.text = company.country;
    m_txtCompanyState.text = company.state;
    m_txtCompanyCity.text = company.city;
    m_txtCompanyZip.text = company.zip;
    m_txtCompanyStreet.text = company.street;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [m_txtCompanyName release];
    [m_txtCompanyCountry release];
    [m_txtCompanyState release];
    [m_txtCompanyCity release];
    [m_txtCompanyStreet release];
    [m_txtCompanyZip release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setM_txtCompanyName:nil];
    [self setM_txtCompanyCountry:nil];
    [self setM_txtCompanyState:nil];
    [self setM_txtCompanyCity:nil];
    [self setM_txtCompanyStreet:nil];
    [self setM_txtCompanyZip:nil];
    [super viewDidUnload];
}

- (IBAction)onClickBtnSave:(id)sender {
    if(m_txtCompanyName.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please input Company Name"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        
        return;
    }
    
    company.name = m_txtCompanyName.text;
    company.country = m_txtCompanyCountry.text;
    company.state = m_txtCompanyState.text;
    company.city = m_txtCompanyCity.text;
    company.zip = m_txtCompanyZip.text;
    company.street = m_txtCompanyStreet.text;
    
    [[ModelManager shared] synchronizeCompanyWithInfo:company.extractDictionary];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
