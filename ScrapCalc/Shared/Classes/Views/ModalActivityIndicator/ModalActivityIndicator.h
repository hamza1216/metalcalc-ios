//
//  ModalActivityIndicator.h
//  ScarpCalc
//
//  Created by Oleksii Starov on 17.10.10.
//  Copyright 2010 home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModalActivityIndicator : UIView {
	UIActivityIndicatorView* loadIndicator;
	UILabel* loadText;
    NSInteger cnt_;
}

- (void)start;
- (void)stop;

@end
