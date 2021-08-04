//
//  MCPushNotificationsViewController.m
//  ScrapCalc
//
//  Created by Diana on 09.08.13.
//
//

#import "MCPushNotificationsViewController.h"
#import "MCPushNotificationCell.h"
#import "MCTextFieldAlert.h"

#define LABEL_TAG 936356

#define SEGM_BADGE      0
#define SEGM_OFF        1
#define SEGM_THRESHOLD  2


@interface MCPushNotificationsViewController () <UITextFieldDelegate, ModelManagerDelegate, MCTripleSwitcherDelegate, MCTextFieldAlertDelegate>
{
    UITextField *editingField_;
    NSInteger selectedRow_;
    UITableViewCell *editingCell_;
    Metal *editingMetal_;
    
    BOOL switcherIsAvailable_iPhone;
}

- (IBAction)editRangeAction:(id)sender;

@end

@implementation MCPushNotificationsViewController

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
    [self initBackButton];
    [self setNavigationTitle:@"PUSH NOTIFICATIONS"];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [ModelManager shared].delegate = self;
    
    switcherIsAvailable_iPhone = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ModelManager shared].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"pushCellID";
    MCPushNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCPushNotificationCell" owner:self options:nil][0];
        [[cell rangeButton] addTarget:self action:@selector(editRangeAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    Metal *metal = [[ModelManager shared] metals][indexPath.row];
    [cell setUpWithMetal:metal];
    [cell switcher].delegate = self;
    cell.switcher.tag = indexPath.section * 1000 + indexPath.row;
    cell.rangeButton.tag = cell.switcher.tag;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)editRangeAction:(UIButton *)sender
{
    NSInteger row = sender.tag % 1000;
    Metal *metal = [[ModelManager shared] metals][row];
    [self _showAlertViewToEnterRangeWithPreviousRange:metal.pushOption.minValue max:metal.pushOption.maxValue];
    editingCell_ = [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] retain];
    editingMetal_ = metal;
    selectedRow_ = row;
}


#pragma mark - MCTripleSlider delegate

- (void)tripleSwitcher:(MCTripleSwitcher *)slider didChangeValue:(NSInteger)value
{
    if (!switcherIsAvailable_iPhone) {
        return;
    }
    
    switcherIsAvailable_iPhone = NO;
    NSInteger row = slider.tag % 1000;
    selectedRow_ = row;
    
    Metal *metal = [[ModelManager shared] metals][row];
    NSDictionary *info = nil;
    
    if (metal.pushOption.isOn == slider.currentType) {
        switcherIsAvailable_iPhone = YES;
        return;
    }
    
    switch ([slider currentType])
    {
        case PushOptionTypeBadge:
        {
            metal.pushOption.isOn = PushOptionTypeBadge;
            info = @{ kPushIsOn:@(metal.pushOption.isOn) };
        }
            break;
            
        case PushOptionTypeOff:
        {
            metal.pushOption.isOn = PushOptionTypeOff;
            info = @{ kPushIsOn:@(metal.pushOption.isOn) };
        }
            break;
            
        case PushOptionTypeThreshold:
        {
            metal.pushOption.isOn = PushOptionTypeThreshold;
            info = @{ kPushIsOn:@(metal.pushOption.isOn), kPushMinVal:@(metal.pushOption.minValue), kPushMaxVal:@(metal.pushOption.maxValue) };
        }
            break;
            
        default:
            break;
    }
    [[ModelManager shared] setDelegate:self];
    [[ModelManager shared] updatePushOptionsForMetal:metal withInfo:info];
    self.table.userInteractionEnabled = NO;
}

- (void)_showAlertViewToEnterRangeWithPreviousRange:(CGFloat)min max:(CGFloat)max
{
    MCTextFieldAlert *alert = [[NSBundle mainBundle] loadNibNamed:@"MCTextFieldAlert" owner:self options:nil][0];
    [[alert minTextField] setText:[NSString stringWithFormat:@"%.2f", min]];
    [[alert maxTextField] setText:[NSString stringWithFormat:@"%.2f", max]];
    alert.minTextField.keyboardType = alert.maxTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    alert.minTextField.delegate = alert.maxTextField.delegate = self;
    [alert setDelegate:self];
    [alert showOnView:self.view];
    
}

#pragma mark - MCTextFieldAlertView delegate methods

- (void)alertViewdidClickOkButton:(MCTextFieldAlert *)alertView
{
    CGFloat min;
    CGFloat max;
    NSString *minStr = alertView.minTextField.text;
    NSString *maxStr = alertView.maxTextField.text;
    if(![minStr isEqualToString:@""] && ![maxStr isEqualToString:@""] && [minStr floatValue] <= [maxStr floatValue])
    {
        min = [minStr floatValue];
        max = [maxStr floatValue];
        
        Metal *metal = [[ModelManager shared] metals][selectedRow_];
        if (!(fabs(metal.pushOption.minValue-min)<0.001 && fabs(metal.pushOption.maxValue-max)<0.001)) {
            self.table.userInteractionEnabled = NO;
            NSDictionary *info = @{ kPushIsOn:@(editingMetal_.pushOption.isOn), kPushMinVal:@(min), kPushMaxVal:@(max) };
            [[ModelManager shared] setDelegate:self];
            [[ModelManager shared] updatePushOptionsForMetal:metal
                                                    withInfo:info];
        }
        editingMetal_.pushOption.minValue = min;
        editingMetal_.pushOption.maxValue = max;
        
        UIButton *button = [(MCPushNotificationCell *)editingCell_ rangeButton];
        button.enabled = (editingMetal_.pushOption.isOn == PushOptionTypeThreshold);
        
        UILabel *label = (UILabel *)[[editingCell_ contentView] viewWithTag:LABEL_TAG];
        [label setText:[self titleForRangeButtonWithMetal:editingMetal_]];
        [label setTextColor:(editingMetal_.pushOption.isOn == PushOptionTypeThreshold) ? [UIColor lightGrayColor] : [UIColor whiteColor]];
        [editingCell_ release];
        editingCell_ = nil;
        editingMetal_ = nil;
    }
}



- (NSString *)titleForRangeButtonWithMetal:(Metal *)metal
{
    return [NSString stringWithFormat:@"%.2f - %.2f", metal.pushOption.minValue, metal.pushOption.maxValue];
}

#pragma mark - UITextField delegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    editingField_ = textField;
    return YES;
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *rezultString = [[editingField_ text] stringByReplacingCharactersInRange:range
                                                                           withString:string];
    if ([rezultString length] == 0)
    {
        return YES;
    }
    
    NSError *error;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[-+]?[0-9]*\\.?[0-9]?[0-9]?$"
                                                                            options:0
                                                                              error:&error];
    if([regexp numberOfMatchesInString:rezultString
                               options:NSMatchingWithoutAnchoringBounds | NSMatchingAnchored
                                 range:NSMakeRange(0, [rezultString length])])
    {
        return YES;
    }
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    editingField_ = nil;
}

#pragma mark - ModelManager delegate 

- (void)didSucceedSendingPushOptions
{
    switcherIsAvailable_iPhone = YES;
    self.table.userInteractionEnabled = YES;
    [self.table reloadData];
}

-(void)didFailSendingPushOptions
{
    NSLog(@"\nfail!\n");
    [[self table] reloadData];
    self.table.userInteractionEnabled = YES;
    switcherIsAvailable_iPhone = YES;
}

-(void)dealloc
{
    [editingCell_ release];
    editingCell_ = nil;
    editingMetal_ = nil;
    [super dealloc];
}

@end
