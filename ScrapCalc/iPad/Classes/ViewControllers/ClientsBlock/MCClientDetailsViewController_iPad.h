//
//  MCClientDetailsViewController_iPad.h
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCBaseDetailViewController_iPad.h"
#import "MCClientsBlockProtocol.h"

typedef enum {
    ClientButtonTagNone,
    ClientButtonTagFirstname,
    ClientButtonTagLastname,
    ClientButtonTagPhone,
    ClientButtonTagEmail,
    ClientButtonTagStreet,
    ClientButtonTagCity,
    ClientButtonTagState,
    ClientButtonTagZip,
    ClientButtonTagCount
} ClientButtonTag;

@class Client;

#define NEWCLIENT_CELL_HEIGHT 60

@interface MCClientDetailsViewController_iPad : MCBaseDetailViewController_iPad <UITextFieldDelegate, UINavigationControllerDelegate,
                                                                                    UITableViewDataSource, UITableViewDelegate, MCClientsListViewControllerDelegate, MCClientDetailsViewControllerDelegate>
{
    NSMutableArray *purchases_;
}

@property (nonatomic, strong) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *clientDetailsPhotoView;
@property (nonatomic, strong) IBOutlet UIButton *associateButton;
@property (nonatomic, strong) IBOutlet UILabel *associateLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollDetailsView;
@property (nonatomic, strong) IBOutlet UITableView *table1;


@property (nonatomic, retain) Client *client;

@property (nonatomic, retain) Purchase *associatePurchase;

@property (nonatomic, assign) id<MCClientDetailsViewControllerDelegate> delegate;

@end
