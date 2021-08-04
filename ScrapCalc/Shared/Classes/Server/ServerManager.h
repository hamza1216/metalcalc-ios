//
//  ServerManager.h
//  ScrapCalc
//
//  Created by Domovik on 09.08.13.
//
//

#import <Foundation/Foundation.h>

#define SERVER      [ServerManager shared]


@protocol ServerManagerDelegate

@optional

- (void)serverDidConfirmTransactionReceipt;
- (void)serverDidRejectTransactionReceipt;

@end


@interface ServerManager : NSObject

@property (nonatomic, assign) NSObject<ServerManagerDelegate> *delegate;

+ (ServerManager *)shared;

- (void)checkTransactionReceipt:(NSString *)receipt withDelegate:(NSObject<ServerManagerDelegate> *)delegate;

@end
