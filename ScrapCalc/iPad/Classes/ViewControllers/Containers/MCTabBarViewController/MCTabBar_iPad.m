//
//  CustomTabBar.m
//  CustomTabBar
//
//  Created by Peter Boctor on 1/2/11.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "MCTabBar_iPad.h"
#import "MCTab.h"

#define SELECTED_ITEM_TAG 2394860

@interface MCTabBar_iPad (PrivateMethods)
-(UIButton*) buttonAtIndex:(NSUInteger)itemIndex width:(CGFloat)width;
@end

@implementation MCTabBar_iPad
@synthesize buttons;

#pragma mark - public methods

-(void)setItemCount:(NSUInteger)itemCount barSize:(CGSize)barSize itemSize:(CGSize)itemSize tag:(NSInteger)objectTag delegate:(NSObject<MCTabBarDelegate> *)customTabBarDelegate
{
    // The tag allows callers withe multiple controls to distinguish between them
    self.tag = objectTag;
    
    // Set the delegate
    delegate = customTabBarDelegate;
    
    // Add the background image
    
    // Initalize the array we use to store our buttons
    self.buttons = [[[NSMutableArray alloc] initWithCapacity:itemCount] autorelease];
    
    // horizontalOffset tracks the proper x value as we add buttons as subviews
    CGFloat horizontalOffset = 0;
    CGFloat widthOfSection = barSize.width/itemCount;
    
    // Iterate through each item
    for (NSUInteger i = 0 ; i < itemCount ; i++)
    {
        // Create a button
        
        MCTab *tab = [customTabBarDelegate tabForItemIndex:i];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownAction:)];
        [tapG setNumberOfTapsRequired:1];
        [tab addGestureRecognizer:tapG];
        [[tab background] setHighlightedImage:[UIImage imageNamed:@"icon_sel_back"]];
        // Add the button to our buttons array
        [buttons addObject:tab];
        
        // Set the button's x offset
        horizontalOffset = widthOfSection*i + widthOfSection/2 - tab.frame.size.width/2;
        
        tab.frame = CGRectMake(horizontalOffset, 0.0, tab.frame.size.width, tab.frame.size.height);
        
        // Add the button as our subview
        [self addSubview:tab];
        
        // Advance the horizontal offset
    }
}

- (void) selectItemAtIndex:(NSInteger)index
{
    // Get the right button to select
    UIView* button = [buttons objectAtIndex:index];
    
    [self dimAllButtonsExcept:button];
}

#pragma mark - private methods

-(void) dimAllButtonsExcept:(UIView*)selectedButton
{
  for (MCTab* button in buttons)
  {
    if (button == (MCTab *)selectedButton)
    {
        [button setSelected:YES];
        button.tag = SELECTED_ITEM_TAG;
    }
    else
    {
        [button setSelected:NO];
        button.tag = 0;
    }
  }
}

- (void)touchDownAction:(UITapGestureRecognizer*)sender
{
    MCTab *butt = (MCTab *)[sender view];
  [self dimAllButtonsExcept:butt];
  if ([delegate respondsToSelector:@selector(touchDownAtItemAtIndex:)])
    [delegate touchDownAtItemAtIndex:[buttons indexOfObject:(MCTab *)butt]];
}


- (void)dealloc
{
  [super dealloc];
  [buttons release];
}


@end
