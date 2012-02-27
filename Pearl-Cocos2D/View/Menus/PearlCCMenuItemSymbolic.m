//
//  PearlCCMenuItemSymbolic.m
//  Pearl
//
//  Created by Maarten Billemont on 08/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlCCMenuItemSymbolic.h"
#import "PearlConfig.h"


@implementation PearlCCMenuItemSymbolic



+ (PearlCCMenuItemSymbolic *)itemFromString:(NSString *)symbol {

    return [self itemFromString:symbol target:nil selector:nil];
}

+ (PearlCCMenuItemSymbolic *)itemFromString:(NSString *)symbol target:(id)aTarget selector:(SEL)aSelector {
    
    return [[[self alloc] initFromString:symbol target:aTarget selector:aSelector] autorelease];
}


- (id)initFromString:(NSString *)symbol {

    return [self initFromString:symbol target:nil selector:nil];
}


- (id)initFromString:(NSString *)symbol target:(id)aTarget selector:(SEL)aSelector {
    
    NSString *oldFontName   = [CCMenuItemFont fontName];
    NSUInteger oldFontSize  = [CCMenuItemFont fontSize];
    [CCMenuItemFont setFontName:[PearlConfig get].symbolicFontName];
    [CCMenuItemFont setFontSize:[[PearlConfig get].largeFontSize unsignedIntValue]];

    @try {
        self = ([super initFromString:symbol target:aTarget selector:aSelector]);
    }
    
    @finally {
        [CCMenuItemFont setFontName:oldFontName];
        [CCMenuItemFont setFontSize:oldFontSize];
    }

    return self;
}

@end