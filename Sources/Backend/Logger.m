//
//  Logger.m
//  iLibs
//
//  Created by Maarten Billemont on 21/08/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Logger.h"

@interface LogMessage : NSObject
{
@private
    NSString                            *message;
    NSDate                              *occurance;
    LogLevel                            level;
}

@property (readwrite, copy) NSString    *message;
@property (readwrite, copy) NSDate      *occurance;
@property (readwrite) LogLevel          level;

+ (LogMessage *)messageWithMessage:(NSString *)aMessage at:(NSDate *)anOccurance withLevel:(LogLevel)aLevel;

- (id)initWithMessage:(NSString *)aMessage at:(NSDate *)anOccurance withLevel:(LogLevel)aLevel;

@end

@implementation LogMessage

@synthesize message, occurance, level;

static NSDateFormatter *logDateFormatter = nil;

+ (void)initialize {

    [super initialize];
    
    if (!logDateFormatter) {
        logDateFormatter = [NSDateFormatter new];
        [logDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [logDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
}


+ (LogMessage *)messageWithMessage:(NSString *)aMessage at:(NSDate *)anOccurance withLevel:(LogLevel)aLevel {

    return [[[self alloc] initWithMessage:aMessage at:anOccurance withLevel:aLevel] autorelease];
}


- (id)initWithMessage:(NSString *)aMessage at:(NSDate *)anOccurance withLevel:(LogLevel)aLevel {

    if (!(self = [super init]))
        return nil;
    
    self.message    = aMessage;
    self.occurance  = anOccurance;
    self.level      = aLevel;
    
    if (!self.occurance)
        self.occurance = [NSDate date];
    
    return self;
}

- (NSString *)description {
    
    NSString *levelString = nil;
    switch (self.level) {
        case LogLevelDebug:
            levelString = @"DEBUG";
            break;
        case LogLevelInfo:
            levelString = @"INFO";
            break;
        case LogLevelWarn:
            levelString = @"WARNING";
            break;
        case LogLevelError:
            levelString = @"ERROR";
            break;
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Formatting a message with a log level that is not understood."];
    }
    
    return [NSString stringWithFormat:@"%@ [%-7@] %@\n",
            [logDateFormatter stringFromDate:self.occurance], levelString, self.message];
}

@end


@implementation Logger

- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    messages = [[NSMutableArray alloc] initWithCapacity:20];
    
    return self;
}


+ (Logger *)get {
    
    static Logger *logger = nil;
    if (!logger)
        logger = [Logger new];
    
    return logger;
}


- (NSString *)formatMessages {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSMutableString *formattedLog = [NSMutableString new];
    for (LogMessage *message in messages)
        [formattedLog appendString:[message description]];
    
    [dateFormatter release];
    
    return [formattedLog autorelease];
}


- (Logger *)logWithLevel:(LogLevel)aLevel andMessage:(NSString *)format, ... {
    
    va_list argList;
    va_start(argList, format);
    
    NSString *messageString = [[NSString alloc] initWithFormat:format arguments:argList];
    LogMessage *message = [LogMessage messageWithMessage:messageString at:nil withLevel:aLevel];
    [messageString release];
    
    va_end(argList);

    NSLog(@"%@", message);
    [messages addObject:message];
    
    return self;
}


- (Logger *)dbg:(NSString *)format, ... {

    va_list argList;
    va_start(argList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
 
    return [self logWithLevel:LogLevelDebug andMessage:[message autorelease]];
}


- (Logger *)inf:(NSString *)format, ... {
    
    va_list argList;
    va_start(argList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    return [self logWithLevel:LogLevelInfo andMessage:[message autorelease]];
}


- (Logger *)wrn:(NSString *)format, ... {
    
    va_list argList;
    va_start(argList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    return [self logWithLevel:LogLevelWarn andMessage:[message autorelease]];
}


- (Logger *)err:(NSString *)format, ... {
    
    va_list argList;
    va_start(argList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    return [self logWithLevel:LogLevelError andMessage:[message autorelease]];
}


@end
