//
//  HomeScreenViewController.m
//  ScrapCalc
//
//  Created by Diana on 09.08.13.
//
//

#import "MCHomeScreenViewController.h"

@interface MCHomeScreenViewController ()

@end

@implementation MCHomeScreenViewController

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
    
    [self setNavigationTitle:@"HOME SCREEN"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ModelManager shared] metals] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForHomeScreenAtIndexPath:indexPath];
    cell.tag = indexPath.section * 1000 + indexPath.row;
    
    UISwitch *sw = (UISwitch *)cell.accessoryView;
    if ([sw isKindOfClass:UISwitch.class]) {
        sw.on = [(Metal *)[[ModelManager shared] metals][indexPath.row] isOn];
    }
    
    cell.textLabel.text = [[[ModelManager shared] metals][indexPath.row] name];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForHomeScreenAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellID = @"SettingsCell-HomeScreen-ID";
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [self homeCellAtIndexPath:indexPath];
    }
    UISwitch *sw = (UISwitch *)cell.accessoryView;
    sw.tag = indexPath.section * 1000 + indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    return cell;   
}

- (UITableViewCell *)homeCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellID = @"SettingsCell-HomeScreen-ID";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:cell.bounds];
    bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
    [cell setBackgroundView:bgView];
    [bgView release];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    sw.onTintColor = [UIColor orangeColor];    
    [sw addTarget:self action:@selector(switcherAction:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    [sw release];
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self table] deselectRowAtIndexPath:indexPath animated:NO];
    Metal *metal = [[ModelManager shared] metals][indexPath.row];
    [[ModelManager shared] updateMetal:metal visibility:!metal.isOn];
    [self.table reloadData];
}

-(void)switcherAction:(UISwitch *)sender
{
    NSInteger row = sender.tag % 1000;
    
    Metal *metal = [[ModelManager shared] metals][row];
    [[ModelManager shared] updateMetal:metal visibility:sender.isOn];
}

@end
