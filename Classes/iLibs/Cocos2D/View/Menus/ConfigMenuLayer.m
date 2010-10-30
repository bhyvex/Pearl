/*
 *   Copyright 2009, Maarten Billemont
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

//
//  ConfigMenuLayer.m
//  iLibs
//
//  Created by Maarten Billemont on 29/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ConfigMenuLayer.h"
#import "Config.h"
#import "MenuItemTitle.h"
#import "NSString_SEL.h"
#import "StringUtils.h"


@interface ConfigMenuLayer ()

- (void)tapped:(id)sender;

@property (readwrite, retain) NSDictionary                         *itemConfigs;

@end

@implementation ConfigMenuLayer

@synthesize itemConfigs = _itemConfigs;
@synthesize configDelegate = _configDelegate;



+ (ConfigMenuLayer *)menuWithDelegate:(id<NSObject, MenuDelegate, ConfigMenuDelegate>)aDelegate logo:(CCMenuItem *)aLogo
                             settings:(SEL)setting, ... {

    if (!setting)
        [NSException raise:NSInvalidArgumentException
                    format:@"No menu items passed."];
    
    va_list list;
    va_start(list, setting);
    SEL item;
    NSMutableArray *settings = [[NSMutableArray alloc] initWithCapacity:5];
    [settings addObject:NSStringFromSelector(setting)];
    
    while ((item = va_arg(list, SEL)))
        [settings addObject:NSStringFromSelector(item)];
    va_end(list);
    
    return [self menuWithDelegate:aDelegate logo:aLogo settingsFromArray:[settings autorelease]];
}


+ (ConfigMenuLayer *)menuWithDelegate:(id<NSObject, MenuDelegate, ConfigMenuDelegate>)aDelegate logo:(CCMenuItem *)aLogo
                    settingsFromArray:(NSArray *)settings {

    return [[[self alloc] initWithDelegate:aDelegate logo:aLogo settingsFromArray:settings] autorelease];
}


- (id)initWithDelegate:(id<NSObject, MenuDelegate, ConfigMenuDelegate>)aDelegate logo:(CCMenuItem *)aLogo
     settingsFromArray:(NSArray *)settings {

    self.configDelegate = aDelegate;

    NSMutableDictionary *mutableItemConfigs = [NSMutableDictionary dictionaryWithCapacity:[settings count]];
    self.itemConfigs = mutableItemConfigs;
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:[settings count]];
    for (NSString *setting in settings) {
        SEL settingSel = NSSelectorFromString(setting);
        
        // Build the setting's toggle button.
        CCMenuItemToggle *menuItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(tapped:)];
        if (self.configDelegate && [self.configDelegate respondsToSelector:@selector(toggleItemsForSetting:)])
            menuItem.subItems = [self.configDelegate toggleItemsForSetting:settingSel];
        if (![menuItem.subItems count])
            menuItem.subItems = [NSMutableArray arrayWithObjects:
                                 [CCMenuItemFont itemFromString:l(@"menu.config.off")],
                                 [CCMenuItemFont itemFromString:l(@"menu.config.on")],
                                 nil];

        // Force update.
        [menuItem setSelectedIndex:[menuItem.subItems count] - 1];
        
        // Build the setting's label.
        NSString *label = nil;
        if (self.configDelegate && [self.configDelegate respondsToSelector:@selector(labelForSetting:)])
            label = [self.configDelegate labelForSetting:settingSel];
        if (!label)
            label = setting;

        // Add the setting to the menu.
        [mutableItemConfigs setObject:setting forKey:[NSValue valueWithPointer:menuItem]];
        [menuItems addObject:[MenuItemTitle itemWithString:label]];
        [menuItems addObject:menuItem];
    }
    
    return [super initWithDelegate:aDelegate logo:aLogo itemsFromArray:[menuItems autorelease]];
}


- (void)onEnter {
    
    [super onEnter];
    
    for (NSValue *itemValue in [self.itemConfigs allKeys]) {
        NSString *selector = [self.itemConfigs objectForKey:itemValue];
        CCMenuItemToggle *item = [itemValue pointerValue];

        id t = [Config get];
        SEL s = NSSelectorFromString(selector);
        
        // Search t's class hierarchy for the selector.
        NSMethodSignature *sig = [t methodSignatureForSelector:s];
        if (!sig)
            [NSException raise:NSInternalInconsistencyException format:@"Couldn't find signature for %s on %@", s, t];
        
        // Build an invocation for the signature & invoke it.
        NSNumber *ret;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:s];
        [invocation invokeWithTarget:t];
        [invocation getReturnValue:&ret];
        
        item.selectedIndex = [ret unsignedIntValue];
    }
}


- (void)tapped:(CCMenuItemToggle *)toggle {
    
    id t = [Config get];
    SEL s = NSSelectorFromString([[self.itemConfigs objectForKey:[NSValue valueWithPointer:toggle]] getterToSetter]);
    void* toggledValue = [NSNumber numberWithUnsignedInt:[toggle selectedIndex]];
    
    // Search t's class hierarchy for the selector.
    NSMethodSignature *sig = [t methodSignatureForSelector:s];
    if (!sig)
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't find signature for %s on %@", s, t];
    
    // Build an invocation for the signature & invoke it.
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:t];
    [invocation setSelector:s];
    [invocation setArgument:&toggledValue atIndex:2];
    [invocation invoke];
}


- (void)dealloc {

    self.configDelegate = nil;
    self.itemConfigs = nil;

    [super dealloc];
}

@end