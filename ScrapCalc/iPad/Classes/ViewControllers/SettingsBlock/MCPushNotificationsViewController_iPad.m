//
//  MCPushNotificationsViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCPushNotificationsViewController_iPad.h"
#import "MCPushNotificationCell_iPad.h"
#import "ModelManager.h"
#import "MCTripleSlider.h"
#import "MCTextFieldAlert.h"

@interface MCPushNotificationsViewController_iPad () <MCTextFieldAlertDelegate, UITextFieldDelegate, ModelManagerDelegate, MCTripleSwitcherDelegate, MCPushNotificationsCellDelegate>
{
    UITextField *editingField_;
    NSInteger selectedRow_;
    MCPushNotificationCell *editingCell_;
    Metal *editingMetal_;
    
    BOOL switcherIsAvailable;
}

@end


@implementation MCPushNotificationsViewController_iPad

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ModelManager shared].delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"PUSH NOTIFICATIONS";
    [self addBackButton];
    self.needsMoveBackButtonToTheContainer = YES;
    switcherIsAvailable = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *cellID = @"pushCellID";
    MCPushNotificationCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCPushNotificationCell_iPad" owner:self options:nil][0];
    }
    Metal *metal = [[ModelManager shared] metals][indexPath.row];
    [cell setUpWithMetal:metal];
    [cell switcher].delegate = self;
    cell.switcher.tag = indexPath.section * 1000 + indexPath.row;
    cell.tag = indexPath.section * 1000 + indexPath.row;
    cell.delegate = self;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)needsBackground
{
    return YES;
}

- (void)_showAlertViewToEnterRangeWithPreviousRange:(CGFloat)min max:(CGFloat)max
{
    MCTextFieldAlert *alert = [[NSBundle mainBundle] loadNibNamed:@"MCTextFieldAlert" owner:self options:nil][0];
    [[alert minTextField] setText:[NSString stringWithFormat:@"%.2f", min]];
    [[alert maxTextField] setText:[NSString stringWithFormat:@"%.2f", max]];
    alert.minTextField.keyboardType = alert.maxTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    alert.minTextField.delegate = alert.maxTextField.delegate = self;
    [alert setDelegate:self];
    [alert showOnView:self.containerView];
}


#pragma mark - MCPushNotificationCell delegate methods

- (void)cellDidTapButton:(MCSettingsCell_iPad *)cell
{
    NSInteger row = cell.tag % 1000;
    Metal *metal = [[ModelManager shared] metals][row];
    [self _showAlertViewToEnterRangeWithPreviousRange:metal.pushOption.minValue max:metal.pushOption.maxValue];
    editingCell_ = (MCPushNotificationCell *)cell;
    editingMetal_ = metal;
    selectedRow_ = [[self.table indexPathForCell:cell] row];
}


#pragma mark - MCTripleSlider delegate

- (void)tripleSwitcher:(MCTripleSwitcher *)slider didChangeValue:(NSInteger)value
{
    if (!switcherIsAvailable)
    {
        return;
    }
    switcherIsAvailable = NO;
    NSInteger row = slider.tag % 1000;
    selectedRow_ = row;
    
    Metal *metal = [[ModelManager shared] metals][row];
    NSDictionary *info = nil;
    
    if (metal.pushOption.isOn == slider.currentType) {
        switcherIsAvailable = YES;
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
    
    [[ModelManager shared] updatePushOptionsForMetal:metal withInfo:info];
    self.table.userInteractionEnabled = NO;
}

#pragma mark - MCTextAlertView delegate methods

- (void)alertViewdidClickOkButton:(MCTextFieldAlert *)alertView
{
    CGFloat min;
    CGFloat max;
    NSString *minStr = alertView.minTextField.text;
    NSString *maxStr = alertView.maxTextField.text;
    if(![minStr isEqualToString:@""] && ![maxStr isEqualToString:@""] && [minStr floatValue] < [maxStr floatValue])
    {
        min = [minStr floatValue];
        max = [maxStr floatValue];
        
        Metal *metal = [[ModelManager shared] metals][selectedRow_];
        if (!(fabs(metal.pushOption.minValue-min) < 0.001 && fabs(metal.pushOption.maxValue-max) < 0.001)) {
            self.table.userInteractionEnabled = NO;
            NSDictionary *info = @{ kPushIsOn:@(editingMetal_.pushOption.isOn), kPushMinVal:@(min), kPushMaxVal:@(max) };
            [[ModelManager shared] updatePushOptionsForMetal:metal withInfo:info];
        }
        editingMetal_.pushOption.minValue = min;
        editingMetal_.pushOption.maxValue = max;
        
    }
}


#pragma mark - UITextField delegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    editingField_ = textField;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *rezultString = [[editingField_ text] stringByReplacingCharactersInRange:range withString:string];
    if ([rezultString length] == 0)
    {
        return YES;
    }
    
    NSError *error;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[-+]?[0-9]*\\.?[0-9]?[0-9]?$" options:0 error:&error];
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

-(void)didSucceedSendingPushOptions
{
    self.table.userInteractionEnabled = YES;
    switcherIsAvailable = YES;
    [[self table] reloadData];
}

-(void)didFailSendingPushOptions
{    
    self.table.userInteractionEnabled = YES;
    switcherIsAvailable = YES;
    [[self table] reloadData];
}

-(void)dealloc
{
    [super dealloc];
    editingCell_ = nil;
    editingMetal_ = nil;
}

@end
