//
//  MCHomeScreenViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCHomeScreenViewController_iPad.h"


@interface MCHomeScreenViewController_iPad ()

@end


@implementation MCHomeScreenViewController_iPad

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
    self.titleLabel.text = @"HOME SCREEN";
    
    [self addBackButton];
    self.needsMoveBackButtonToTheContainer = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ModelManager shared] metals] count];
}

- (void)setupCell:(MCSettingsCell_iPad *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.cellType = MCSettingsCellTypeOnOff;
    
    Metal *metal = [[ModelManager shared] metals][indexPath.row];
    cell.titleLabel.text = metal.name;
    cell.isChecked = metal.isOn;
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Metal *metal = [[ModelManager shared] metals][indexPath.row];
    [[ModelManager shared] updateMetal:metal visibility:!metal.isOn];
    [self.table reloadData];
}

- (void)cell:(MCSettingsCell_iPad *)cell didChangeValue:(BOOL)newValue
{
    NSInteger row = cell.tag % 1000;
    
    Metal *metal = [[ModelManager shared] metals][row];
    [[ModelManager shared] updateMetal:metal visibility:newValue];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


@end
