//
//  MCScrollView.h
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import <UIKit/UIKit.h>


@protocol MCScrollViewDelegate

@optional
- (void)scrollDidChangeIndex:(NSInteger)theIndex;

@end


@interface MCScrollView : UIView <UIScrollViewDelegate> {
    NSInteger dsMultiplier_;
    UIScrollView *scroll_;
    NSMutableArray *visibleLabels_;
    NSInteger delta;
}

@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, assign) NSObject<MCScrollViewDelegate> *scrollDelegate;

- (void)reloadData;
- (void)updateScrollAnimated:(BOOL)animated;
- (void)setupForItem:(NSInteger)item;

@end
