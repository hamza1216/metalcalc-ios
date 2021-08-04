//
//  NSURLConnection+Blocks.h
//  ShowMeGolfLibrary
//
//  Created by Vladimir Gogunsky on 12/25/12.
//  Copyright (c) 2012 Vladimir Gogunsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Blocks)

+ (void)asyncRequest:(NSURLRequest *)request success:(void(^)(NSData *,NSURLResponse *))successBlock_ failure:(void(^)(NSData *,NSError *))failureBlock_;

@end
