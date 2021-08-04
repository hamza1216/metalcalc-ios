//
//  DotTextField.m
//  ScrapCalc
//
//  Created by word on 10.05.13.
//
//

#import "DotTextField.h"

@implementation DotTextField

- (NSString *)text
{
    return [super.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)setText:(NSString *)theText
{
    super.text = [theText stringByReplacingOccurrencesOfString:@"." withString:@","];
}

@end
