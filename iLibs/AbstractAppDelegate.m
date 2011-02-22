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
//  AbstractAppDelegate.m
//  iLibs
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "AbstractAppDelegate.h"
#import "Logger.h"
#import "Config.h"
#import "AudioController.h"
#import "Resettable.h"
#import "AlertViewController.h"
#import "RootViewController.h"
#import "CryptUtils.h"


@implementation AbstractAppDelegate
@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Log application details.
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleName"];
    NSString *displayName = [info objectForKey:@"CFBundleDisplayName"];
    NSString *build = [info objectForKey:@"CFBundleVersion"];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *copyright = [info objectForKey:@"NSHumanReadableCopyright"];
    
    if (!name)
        name = displayName;
    if (displayName && ![displayName isEqualToString:name])
        name = [NSString stringWithFormat:@"%@ (%@)", displayName, name];
    if (!version)
        version = build;
    if (build && ![build isEqualToString:version])
        version = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    inf(@"%@ v%@", name, version);
    if (copyright)
        inf(@"%@", copyright);
    inf(@"===================================");
	
    if ([[Config get].supportedNotifications unsignedIntegerValue])
        [application registerForRemoteNotificationTypes:[[Config get].supportedNotifications unsignedIntegerValue]];

    // Start the background music.
    [self preSetup];
    
    return NO;
}


- (void)preSetup {

    if ([[Config get].currentTrack isEqualToString:@"sequential"]) {
        // Restart sequentially from the start.
        [Config get].playingTrack = nil;
        [[AudioController get] playTrack:@"sequential"];
    } else
        [[AudioController get] playTrack:[Config get].currentTrack];

    if (!self.window) {
        self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        self.window.rootViewController = [[RootViewController new] autorelease];
    }
}


- (void)didUpdateConfigForKey:(SEL)configKey {
    
}

- (void)restart {

    [self.window.rootViewController.navigationController popToRootViewControllerAnimated:YES];
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    [[AlertViewController currentAlert] dismissAlert];
}

- (void)shutdown:(id)caller {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [Config get].deviceToken = deviceToken;
    [Config get].notificationsSupported = [NSNumber numberWithBool:YES];
    [Config get].notificationsChecked = [NSNumber numberWithBool:YES];
    
    dbg(@"APN Device Token Hex: %@", [deviceToken hex]);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [Config get].notificationsSupported = [NSNumber numberWithBool:NO];
    [Config get].notificationsChecked = [NSNumber numberWithBool:YES];
    
    wrn(@"Couldn't register with the APNs: %@", error);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [self cleanup];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [Config get].firstRun = [NSNumber numberWithBool:NO];
}

- (void)cleanup {
    
    [[AudioController get] playTrack:nil];
}

- (void)dealloc {
    
    self.window = nil;
    
    [super dealloc];
}

+(AbstractAppDelegate *) get {
    
    return (AbstractAppDelegate *) [[UIApplication sharedApplication] delegate];
}


@end
