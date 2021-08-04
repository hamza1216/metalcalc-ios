//
//  MCNewClientViewController.h
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "BaseViewController.h"
#import "ModelManager.h"
#import <QuartzCore/QuartzCore.h>

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

@interface MCNewClientViewController : BaseViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *purchases_;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet UIView *finishView;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet UILabel *addPhotoLabel;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *associateButton;
@property (nonatomic, strong) IBOutlet UILabel *associateLabel;
@property (nonatomic, strong) IBOutlet UIView *addPhotoView;
@property (nonatomic, retain) Client *client;

@property (nonatomic, retain) Purchase *associatePurchase;
@property (nonatomic, assign) BOOL selectClient;

@end
