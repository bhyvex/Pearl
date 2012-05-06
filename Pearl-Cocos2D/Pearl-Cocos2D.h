#ifndef PEARL_COCOS2D
#error PEARL_COCOS2D used but not enabled.  If you want to use this library, first enable it with #define PEARL_COCOS2D in your Pearl prefix file.
#endif

#if ! __has_feature(objc_arc)
#error PEARL_COCOS2D requires ARC.  Change your build settings to enable ARC support in your compiler and try again.
#endif

#import "Pearl-Cocos2D-Dependencies.h"
#import "Pearl.h"
#import "PearlCCAutoTween.h"
#import "PearlCCRemove.h"
#import "PearlCCDebug.h"
#import "PearlCocos2DAppDelegate.h"
#import "PearlCocos2DStrings.h"
#import "PearlGLShaders.h"
#import "PearlCCConfigMenuLayer.h"
#import "PearlCCMenuItemBlock.h"
#import "PearlCCMenuItemSpacer.h"
#import "PearlCCMenuItemSymbolic.h"
#import "PearlCCMenuItemTitle.h"
#import "PearlCCMenuLayer.h"
#import "PearlCCActivitySprite.h"
#import "PearlCCBarLayer.h"
#import "PearlCCBarSprite.h"
#import "PearlCCBoxLayer.h"
#import "PearlCCDebugLayer.h"
#import "PearlCCFancyLayer.h"
#import "PearlCCFlickLayer.h"
#import "PearlCCHUDLayer.h"
#import "PearlCCScrollLayer.h"
#import "PearlCCShadeLayer.h"
#import "PearlCCSplash.h"
#import "PearlCCSwipeLayer.h"
#import "PearlCCUILayer.h"
#import "PearlGLUtils.h"
