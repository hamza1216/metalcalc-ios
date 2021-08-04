//
//  MCBaseViewControllerProtocol.h
//  ScrapCalc
//
//  Created by Domovik on 06.08.13.
//
//

#import <Foundation/Foundation.h>

@class MCSplitViewController;

@protocol MCBaseViewControllerProtocol <NSObject>

- (void)setupForPortrait;
- (void)setupForLandscape;

@end
