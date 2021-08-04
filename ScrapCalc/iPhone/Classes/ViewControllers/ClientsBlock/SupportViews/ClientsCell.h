//
//  ClientsCell.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import <UIKit/UIKit.h>
    
#define CLIENT_CELL_HEIGHT      68
#define CLIENT_ICON_FRAME       CGRectMake(0,1,CLIENT_CELL_HEIGHT-2,CLIENT_CELL_HEIGHT-2)
#define CLIENT_NAME_FRAME       CGRectMake(CLIENT_CELL_HEIGHT+4,0,220,CLIENT_CELL_HEIGHT)
#define CLIENT_ARROW_FRAME      CGRectMake(self.frame.size.width-40, (CLIENT_CELL_HEIGHT-28)/2, 28, 28)
#define CLIENT_SEPARATOR_FRAME  CGRectMake(0, CLIENT_CELL_HEIGHT-2, self.contentView.frame.size.width, 2)

@interface ClientsCell : UITableViewCell {
    UIImageView *iconView_;
    UILabel *nameLabel_;
    UIImageView *separatorImageView_;
}

- (void)setIcon:(UIImage *)icon;
- (void)setDefaultIcon;
- (void)setName:(NSString *)name;

@end
