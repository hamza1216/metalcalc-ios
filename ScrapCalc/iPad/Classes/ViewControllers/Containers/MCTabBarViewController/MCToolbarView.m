//
//  MCToolbarView.m
//  Solution
//
//  Created by Domovik on 07.08.13.
//  Copyright (c) 2013 Domovik. All rights reserved.
//

#import "MCToolbarView.h"
#import "MCTab.h"


@interface MCToolbarView ()

@property (nonatomic, strong) MCTabBar_iPad *tabBarPrivate;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end


@implementation MCToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:TOOLBAR_FRAME_FULL];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.backgroundImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    self.backgroundImageView.image = [UIImage imageNamed:@"menu_back.png"];
    [self addSubview:self.backgroundImageView];
    
    self.tabBarPrivate = [[[MCTabBar_iPad alloc] initWithFrame:TOOLBAR_FRAME_BAR] autorelease];
    self.tabBarPrivate.center = self.center;
    self.tabBarPrivate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.tabBarPrivate setItemCount:MCTabItemsCount barSize:self.tabBarPrivate.frame.size itemSize:CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT) tag:0 delegate:self];
    [self addSubview:self.tabBarPrivate];
    
    UIButton *toolbarLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:toolbarLeftButton];
    [toolbarLeftButton setHidden:YES];
    self.leftButton = toolbarLeftButton;
    
    UIButton *toolbarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:toolbarRightButton];
    [toolbarRightButton setHidden:YES];
    self.rightButton = toolbarRightButton;
}


#pragma mark - Public

- (MCTabBar_iPad *)tabBar
{
    return self.tabBarPrivate;
}

- (void)setDelegate:(NSObject<MCToolbarViewDelegate> *)delegate
{
    _delegate = delegate;
    [self selectTabIndex:0];
}

- (void)selectTabIndex:(NSInteger)index
{
    [self.tabBarPrivate selectItemAtIndex:index];
    [self touchDownAtItemAtIndex:index]; 
}


#pragma mark - MCTabBar delegate methods

- (void) touchDownAtItemAtIndex:(NSUInteger)itemIndex
{
    if ([self.delegate respondsToSelector:@selector(toolbarDidSelectItemAtIndex:)]) {
        [self.delegate toolbarDidSelectItemAtIndex:itemIndex];
    }
}

-(MCTab *)tabForItemIndex:(NSInteger)index
{
    switch (index) {
        case MCTabClients:
            return [self clientTab];
            break;
        case MCTabMetalList:
            return [self metalListTab];
            break;
        case MCTabPurchases:
            return [self purchasesTab];
            break;
        case MCTabSettings:
            return [self settingsTab];
            break;
    }
    return nil;
}

-(MCTab *)commonTab
{
    MCTab *res = [[NSBundle mainBundle] loadNibNamed:@"MCTab" owner:self options:nil][0];
    return res;
}

-(MCTab *)clientTab
{
    MCTab *clientTab = [self commonTab];
    [[clientTab title] setText:@"Clients"];
    [[clientTab icon] setImage:[UIImage imageNamed:@"icon_user_norm"]];
    [[clientTab icon] setHighlightedImage:[UIImage imageNamed:@"icon_user_sel"]];
    return clientTab;
}

-(MCTab *)metalListTab
{
    MCTab *metalTab = [self commonTab];
    [[metalTab title] setText:@"Metals list"];
    [[metalTab icon] setImage:[UIImage imageNamed:@"icon_list_norm"]];
    [[metalTab icon] setHighlightedImage:[UIImage imageNamed:@"icon_list_sel"]];
    return metalTab;
}

-(MCTab *)purchasesTab
{
    MCTab *purchasesTab = [self commonTab];
    [[purchasesTab title] setText:@"Purchases"];
    [[purchasesTab icon] setImage:[UIImage imageNamed:@"icon_purchase_norm"]];
    [[purchasesTab icon] setHighlightedImage:[UIImage imageNamed:@"icon_purchase_sel"]];
    return purchasesTab;
}

-(MCTab *)settingsTab
{
    MCTab *settingsTab = [self commonTab];
    [[settingsTab title] setText:@"Settings"];
    [[settingsTab icon] setImage:[UIImage imageNamed:@"icon_settings_norm"]];
    [[settingsTab icon] setHighlightedImage:[UIImage imageNamed:@"icon_settings_sel"]];
    return settingsTab;
}


#pragma mark - Memory management

- (void)dealloc
{
    self.tabBarPrivate = nil;
    self.backgroundImageView = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    [super dealloc];
}

@end
