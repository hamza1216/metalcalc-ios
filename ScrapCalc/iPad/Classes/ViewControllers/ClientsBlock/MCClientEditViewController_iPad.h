//
//  MCClientEditViewController.h
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCBaseDetailViewController_iPad.h"
#import "MCClientDetailsViewController_iPad.h"
#import "MCClientsBlockProtocol.h"

@interface MCClientEditViewController_iPad : MCBaseDetailViewController_iPad <UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *purchases_;
}
@property (nonatomic, assign) BOOL isNewClient;
@property (nonatomic, retain) Client *client;
@property (nonatomic, retain) Purchase *associatePurchase;
@property (nonatomic, assign) BOOL selectClient;

@property (nonatomic, strong) IBOutlet UIImageView *clientEditPhotoView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollNewClient;
@property (nonatomic, strong) IBOutlet UIView *finishView;
@property (nonatomic, strong) IBOutlet UITableView *tablePurchases;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIView *addPhotoView;
@property (nonatomic, assign) id<MCClientDetailsViewControllerDelegate> delegate;

@end
