//
//  MCClientsBlockProtocol.h
//  ScrapCalc
//
//  Created by Diana on 07.08.13.
//
//

#import <Foundation/Foundation.h>

@protocol MCClientsListViewControllerDelegate <NSObject>

-(void)didChooseClient:(Client *)client;

-(void)addNewClient;

@end

@protocol MCClientDetailsViewControllerDelegate <NSObject>

- (void)didCancel;

- (void)clientDetailsDidUpdate:(Client *)client;

- (void)newClientWasAdded:(Client *)client;

- (void)setAddPurchaseButtonHidden:(BOOL)hidden;

@optional

- (void)willEditClient:(Client *)client;

@end
