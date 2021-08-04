//
//  MCTab.h
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import <UIKit/UIKit.h>

#define ITEM_WIDTH      157.0
#define ITEM_HEIGHT      33.0


@interface MCTab : UIView

@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic) BOOL selected;

@end
