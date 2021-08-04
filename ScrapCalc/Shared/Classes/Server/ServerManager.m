//
//  ServerManager.m
//  ScrapCalc
//
//  Created by Domovik on 09.08.13.
//
//

#import "ServerManager.h"
#import "NSURLConnection+Blocks.h"
#import "JSONKit.h"


@implementation ServerManager


static ServerManager *shared_;

+ (ServerManager *)shared
{
    @synchronized(self) {
        if (shared_ == nil) {
            shared_ = [ServerManager new];
        }
        return shared_;
    }
}


#pragma mark - Transaction Receipt

- (void)checkTransactionReceipt:(NSString *)receipt withDelegate:(NSObject<ServerManagerDelegate> *)delegate
{
    NSLog(@"check transactions receipt\n");
    self.delegate = delegate;
    
    NSString *real_receipt = @"false";
    
#ifdef RELEASE
    real_receipt = @"true";
#endif
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://burkardsolutions.com/iphone/check_purchase.php?sandbox_receipt=%@",real_receipt]]];
	[postRequest setHTTPMethod:@"POST"];
    
    NSData *body = [[NSString stringWithFormat:@"receipt_data=%@", receipt] dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:body];
    
    [APP_DELEGATE showLoadingIndicator];
    [NSURLConnection asyncRequest:postRequest
                          success:^(NSData *data, NSURLResponse *response) {
                              
                              NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                              NSDictionary *info = [json objectFromJSONString];
                              
                              if ([info[@"status"] integerValue]) {
                                  NSLog(@"reject transaction receipt\n");
                                  [self.delegate serverDidRejectTransactionReceipt];
                              }
                              else {
                                  NSLog(@"confirm transaction receipt");
                                  
                                  // ATTENTION: Next is correct for auto-renewable, but not for non-renewable subscription
                                  NSDictionary *receiptDict = info[@"latest_receipt_info"];
                                  NSString *purchDate = receiptDict[@"purchase_date_ms"];
                                  NSLog(@"purchase date - %@\n", purchDate);
                                  NSString *expDate = receiptDict[@"expires_date"];
                                  NSLog(@"expiration date - %@\n", expDate);
                                  NSString *productID = receiptDict[@"product_id"];
                                  NSLog(@"product id - %@\n", productID);
                                  
                                  [[NSUserDefaults standardUserDefaults] setObject:purchDate forKey:@"purchasedTimestamp"];
                                  [[NSUserDefaults standardUserDefaults] setObject:expDate   forKey:@"expiresTimestamp"];
                                  [[NSUserDefaults standardUserDefaults] setObject:productID forKey:@"productID"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
//                                  NSDictionary *receiptDict = info[@"receipt"];
//                                  double purchasedTimestamp = [receiptDict[@"purchase_date_ms"] doubleValue];
//                                  NSString *productID = receiptDict[@"product_id"];
//                                  
//                                  [[NSUserDefaults standardUserDefaults] setObject:@(purchasedTimestamp) forKey:@"purchasedTimestamp"];
//                                  [[NSUserDefaults standardUserDefaults] setObject:productID forKey:@"productID"];
//                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  [self.delegate serverDidConfirmTransactionReceipt];
                              }
                          }
                          failure:^(NSData *data, NSError *error) {
                              NSLog(@"reject transaction receipt\n");
                              [self.delegate serverDidRejectTransactionReceipt];    // consider reject is equal to failure, for now
                          }];
}


@end
