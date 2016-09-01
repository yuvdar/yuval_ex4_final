// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import <Foundation/Foundation.h>
#import "Deck.h"
NS_ASSUME_NONNULL_BEGIN

@interface CardMatchingGame : NSObject

-(instancetype) initWithCardCount:(NSUInteger)count  usingDeck:(Deck *)deck;

-(void)chooseCardAtIndex:(NSUInteger)index;
-(Card *)cardAtIndex:(NSUInteger)index;
@property (nonatomic) NSUInteger numOfCardToMatch; // int+2 card match
@property (nonatomic, readonly) NSInteger score;
@property (nonatomic) BOOL choosingPenalty;
@end

NS_ASSUME_NONNULL_END
