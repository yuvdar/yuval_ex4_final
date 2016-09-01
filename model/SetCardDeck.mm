// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "SetCardDeck.h"
#import "SetCard.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SetCardDeck

- (instancetype) init
{
  
  
  if (self = [super init]){
    for (NSString *suit in [SetCard validSuits]){
      for (NSUInteger rank=1; rank <= [SetCard maxRank]; rank++){
        for (NSString *color in [SetCard validColors]){
          for (NSString *shade in [SetCard validfill]){
            SetCard *card = [[SetCard alloc] init];
            card.rank = rank;
            card.suit = suit;
            card.color = color;
            card.shading = shade;
            [self addCard:card];
          }
        }
      }
    }
  }
  return self;
}


@end

NS_ASSUME_NONNULL_END
