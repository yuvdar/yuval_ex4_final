// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import <Foundation/Foundation.h>

#import "Card.h"

NS_ASSUME_NONNULL_BEGIN

@interface Deck : NSObject
- (void)addCard:(Card *)card atTop:(BOOL)atTop;
- (void)addCard:(Card *)card;
-(Card *)drawRandomCard;

@end

NS_ASSUME_NONNULL_END
