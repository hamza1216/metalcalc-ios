

#import "SPLogger.h"

static NSString * const LOGS_FOLDER         = @"LOGS";
static NSString * const LOGS_SUFIX          = @"-logs.txt";
static NSString * const DATE_TIME_MASK      = @"YYYY-mm-dd HH:mm:ss";
static NSString * const DATE_MASK           = @"YYYY-mm-dd";
static NSString * const VERSION_KEY         = @"CFBundleVersion";
static NSString * const OUTPUT_FORMAT       = @"%@ %@ :%s Line:%d - %@";

@interface SPLogger ()

NSString * currentTime();
NSString * logFileName();
NSString * pathToLogsFolder();
NSString * versionFolderName();

void createFolderAtPath(NSString *path);
void append(NSString *msg);

@end

@implementation SPLogger


#pragma mark - Public -

void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...)
{
    va_list ap;
    va_start (ap, format);
    format = [format stringByAppendingString:@"\n"];
    NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@",format] arguments:ap];
    va_end (ap);
    
    NSString *log = [NSString stringWithFormat:OUTPUT_FORMAT, prefix, currentTime(), funcName, lineNumber, msg];
    
    fprintf(stderr,"%s", [log UTF8String]);
    
    append(log);
}

void clearLogs()
{
    [[NSFileManager defaultManager] removeItemAtPath:pathToLogsFolder() error:nil];
}

#pragma mark - Private -


void append(NSString *msg)
{
    NSString *path = pathToLogsFolder();
    
    createFolderAtPath(path);
    
    path = [path stringByAppendingPathComponent:versionFolderName()];
   
    createFolderAtPath(path);
    
    path = [path stringByAppendingPathComponent:logFileName()];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSData data] writeToFile:path atomically:YES];
    }

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

NSString * logFileName()
{    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_MASK];
    NSString * currentDate = [formatter stringFromDate:[NSDate date]];
    
    return [currentDate stringByAppendingFormat:LOGS_SUFIX];
}

NSString * pathToLogsFolder()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:LOGS_FOLDER];
   
    return path;
}

NSString * versionFolderName()
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:VERSION_KEY];

    return appVersion;
}

NSString * currentTime()
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_TIME_MASK];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    return time;
}

void createFolderAtPath(NSString *path)
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:FALSE
                                                   attributes:nil
                                                        error:nil];
    }
}

@end
