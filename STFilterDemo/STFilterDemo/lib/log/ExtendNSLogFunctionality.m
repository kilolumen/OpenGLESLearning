//
//  ExtendNSLogFunctionality.m
//  ExtendNSLog

#import "ExtendNSLogFunctionality.h"

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;

    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    //    NSLocale *currlocal = [NSLocale currentLocale];
    //    [outputFormatter setLocale:currlocal];
    [outputFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [outputFormatter setDateStyle:NSDateFormatterShortStyle];
    [outputFormatter setTimeStyle:NSDateFormatterShortStyle];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *date = [outputFormatter stringFromDate:[NSDate date]];
    [outputFormatter release];
    
//    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "\n%s %s %s line:%d\n%s",[date UTF8String],[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] UTF8String], functionName,
            lineNumber, [body UTF8String]);
    //[fileName UTF8String]
    [body release];
}

@implementation ExtendNSLogFunctionality

@end
