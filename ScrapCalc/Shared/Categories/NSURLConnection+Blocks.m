//
//  NSURLConnection+Blocks.m
//  ShowMeGolfLibrary
//
//  Created by Vladimir Gogunsky on 12/25/12.
//  Copyright (c) 2012 Vladimir Gogunsky. All rights reserved.
//

#import "NSURLConnection+Blocks.h"

@implementation NSURLConnection (Blocks)

#pragma mark API
+ (void)asyncRequest:(NSURLRequest *)request success:(void(^)(NSData *,NSURLResponse *))successBlock_ failure:(void(^)(NSData *,NSError *))failureBlock_
{
    [NSThread detachNewThreadSelector:@selector(backgroundSync:) toTarget:[NSURLConnection class]
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       request,@"request",
                                       [[successBlock_ copy] autorelease],@"success",
                                       [[failureBlock_ copy] autorelease],@"failure",
                                       nil]];
}

#pragma mark Private
+ (void)backgroundSync:(NSDictionary *)dictionary
{

    void(^success)(NSData *,NSURLResponse *) = [dictionary objectForKey:@"success"];
    void(^failure)(NSData *,NSError *) = [dictionary objectForKey:@"failure"];
    NSURLRequest *request = [dictionary objectForKey:@"request"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        failure(data,error);
    }
    else
    {
        success(data,response);
    }
}



@end
