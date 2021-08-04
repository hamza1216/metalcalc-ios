//
//  MCPrivacyPolicyViewController.h
//  MetalCalcPlus
//
//  Created by Xian Huang on 2/17/20.
//
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCPrivacyPolicyViewController : BaseViewController<UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *m_webView;
@property (nonatomic, strong) NSString *loadHtmlName;
@end

NS_ASSUME_NONNULL_END
