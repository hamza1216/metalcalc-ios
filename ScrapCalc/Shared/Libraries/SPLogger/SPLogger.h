

#import <Foundation/Foundation.h>

#define NSLog(args...) _Log(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);

@interface SPLogger : NSObject

void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...);
void clearLogs();

@end
