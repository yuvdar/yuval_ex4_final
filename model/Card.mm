// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "Card.h"

NS_ASSUME_NONNULL_BEGIN
@interface Card()

@end

@implementation Card

- (int)match:(NSArray *)otherCards{
    int score =0;
    for (Card *card in otherCards){
      if ([card.contents isEqualToString:self.contents]){
        score =1;
      }
    }
    return score;
}

@end

NS_ASSUME_NONNULL_END
