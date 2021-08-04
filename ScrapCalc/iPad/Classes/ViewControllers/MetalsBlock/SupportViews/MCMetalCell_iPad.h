//
//  MCMetalCell_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Metal.h"

#define MCMetallCelliPad_Height     70
#define kDiamondsName               @"diamonds"


typedef NS_ENUM(NSInteger, MCMetalCellType)
{
    MCMetalCellTypeNormalShort,
    MCMetalCellTypeNormalLong,
    MCMetalCellTypeSelectedShort,
    MCMetalCellTypeSelectedLong
};

NS_INLINE UIImage *
MCMetalCellBackgroundImage(MCMetalCellType type)
{
    NSString *name = @"";
    switch (type)
    {
        case MCMetalCellTypeNormalShort:    name = @"list_item_short.png";      break;
        case MCMetalCellTypeNormalLong:     name = @"list_item_long.png";       break;
        case MCMetalCellTypeSelectedShort:  name = @"list_item_short_sel.png";  break;
        case MCMetalCellTypeSelectedLong:   name = @"list_item_long_sel.png";   break;
        default: break;
    }
    return [UIImage imageNamed:name];
}

NS_INLINE UIImage *
MCMetalCellArrowImage(MCMetalCellType type)
{
    NSString *name = @"";
    switch (type)
    {
        case MCMetalCellTypeNormalShort:
        case MCMetalCellTypeNormalLong:     name = @"list_arrow_norm.png";  break;
        case MCMetalCellTypeSelectedShort:
        case MCMetalCellTypeSelectedLong:   name = @"list_arrow_sel.png";   break;
        default: break;
    }
    return [UIImage imageNamed:name];
}

NS_INLINE UIImage *
MCMetalCellNameImage(NSString *metalName, MCMetalCellType type)
{
    NSString *imageName = [NSString stringWithFormat:@"metal_%@_%@.png", metalName.lowercaseString, (type > MCMetalCellTypeNormalLong ? @"norm" : @"sel")];
    return [UIImage imageNamed:imageName];
}


@interface MCMetalCell_iPad : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain) IBOutlet UIImageView *nameImageView;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;

- (void)setupWithType:(MCMetalCellType)type andMetal:(Metal *)metal;

@end
