// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "PlayingCard.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PlayingCard

// if all suit - 2^(N-1), rank 8^(N-1)
// if M matched  - suit 2^(2M-N) / rank (only valid if N<=4,  8^(2M-N)
-(int)match:(NSArray *)otherCards
{
  int score = 0;
  NSUInteger numberOfCards = [otherCards count] ;
  BOOL allMatchedSuit = YES;
  BOOL allMatchedRank = YES;
  int suitMatched = 0;
  int rankMatched = 0;
  if (numberOfCards == 0){
    return 0;
  }
  // checking matches agains self:
  for (PlayingCard *otherCard in otherCards){
    if ([self.suit isEqualToString:otherCard.suit]){
      suitMatched ++;
    } else {
      allMatchedSuit = NO;
    }
    if (self.rank == otherCard.rank) {
      rankMatched++;
    } else {
      allMatchedRank = NO;
    }
  }
  if (allMatchedRank){
    return (int)pow(8,numberOfCards);
  }
  if (allMatchedSuit){
    return (int)pow(2,numberOfCards);
  }
  // keep counting matches between other cards
  
  if ([otherCards count] > 1){
    NSMutableArray *lessCards = [otherCards mutableCopy];
    
    for (PlayingCard *otherCard in otherCards){
      [lessCards removeObject:otherCard];
      if ([lessCards count] >= 1){
        for (PlayingCard *thirdCard in lessCards){
          if ([otherCard.suit isEqualToString:thirdCard.suit]){
            suitMatched ++;
          }
          if (otherCard.rank == thirdCard.rank) {
            rankMatched++;
          }
        }
        
      }
    }
    if (rankMatched == 0 && suitMatched == 0){
      return 0;
    }
    if (rankMatched >= suitMatched){
      score = (int)(pow(8,2*(1+rankMatched)-numberOfCards-1))>>1;
    } else {
      score = (int)(pow(2,2*(1+suitMatched)-numberOfCards-1))>>1;
    }
  }
  
  return score;
}


- (NSString *)contents
{
  NSArray *rankStrings = [PlayingCard rankStrings];
  return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

@synthesize suit = _suit;


+ (NSArray *)validSuits
{
  return @[@"♠",@"♣",@"♥",@"♦"];
}
+ (NSArray *) rankStrings
{
  return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}



- (void)setSuit:(NSString *)suit
{
  if ([[PlayingCard validSuits] containsObject:suit]){
    _suit = suit;
  }
    
}

- (NSString *)suit
{
  return _suit ? _suit : @"?";
}


+ (NSUInteger)maxRank { return [[self rankStrings] count]-1;}

-(void)setRank:(NSUInteger)rank{
  if (rank <= [PlayingCard maxRank]){
    _rank = rank;
  }
        
}

@end

NS_ASSUME_NONNULL_END
