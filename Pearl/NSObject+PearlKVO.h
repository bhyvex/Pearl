/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  NSObject(PearlKVO)
//
//  Created by Maarten Billemont on 02/06/12.
//  Copyright 2012 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PearlKVO)

- (void)addObserverBlock:(void(^)(NSString *keyPath, id object, NSDictionary *change, void *context))observerBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

@end