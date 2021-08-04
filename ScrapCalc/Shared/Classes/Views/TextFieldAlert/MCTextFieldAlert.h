//
//  MCTextFieldAlert.h
//  ScrapCalc
//
//  Created by Diana on 14.10.13.
//
//

#import <UIKit/UIKit.h>

@class MCTextFieldAlert;

@protocol MCTextFieldAlertDelegate <NSObject>

@optional

- (void)alertViewdidClickOkButton:(MCTextFieldAlert *)alertView;

- (void)alertViewdidClickCancelButton:(MCTextFieldAlert *)alertView;

@end

@interface MCTextFieldAlert : UIView

@property (nonatomic, assign) id <MCTextFieldAlertDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *maxTextField;
@property (nonatomic, strong) IBOutlet UITextField *minTextField;

- (void)showOnView:(UIView *)view;

@end
