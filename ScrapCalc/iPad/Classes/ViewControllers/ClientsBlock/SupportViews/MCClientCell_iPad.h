//
//  MCClientCell_iPad.h
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import <UIKit/UIKit.h>
#define CLIENT_CELL_HEIGHT      68
#define CLIENT_NAME_WIDTH_FULL  580.0
#define CLIENT_NAME_WIDTH_SHORT 170.0
#define CLIENT_ICON_FRAME       CGRectMake(10,1,CLIENT_CELL_HEIGHT-2,CLIENT_CELL_HEIGHT-2)
#define CLIENT_NAME_FRAME       CGRectMake(CLIENT_CELL_HEIGHT+14,0,CLIENT_NAME_WIDTH_SHORT,CLIENT_CELL_HEIGHT)
#define CLIENT_ARROW_FRAME      CGRectMake(self.frame.size.width-40, (CLIENT_CELL_HEIGHT-28)/2, 28, 28)
#define CLIENT_SEPARATOR_FRAME  CGRectMake(0, self.contentView.frame.size.height-2, self.contentView.frame.size.width, 2)
@interface MCClientCell_iPad : UITableViewCell
{
    UIImageView *iconView_;
    UIImageView *bgView_;
    UIImageView *bgSelectedView_;
    UILabel *nameLabel_;
    UIImageView *arrowImageView_;
}

- (void)setIcon:(UIImage *)icon;
- (void)setName:(NSString *)name;

-(void)updateClientCell:(BOOL)isPortrait;

@end
