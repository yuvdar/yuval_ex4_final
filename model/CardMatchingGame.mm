// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "CardMatchingGame.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardMatchingGame()

@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards; // of Card
@property (nonatomic, readwrite) NSInteger chosenNum;

@end

@implementation CardMatchingGame

-(NSMutableArray *)cards
{
  if(!_cards) _cards = [[NSMutableArray alloc] init];
  return _cards;
}

-(instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
  
  if (self  = [super init]) {
    self.chosenNum = 0;
    for (int i=0; i<count; i++){
      Card *card = [deck drawRandomCard];
      if (card){
        [self.cards addObject:card];
      } else {
        self = nil;
        break;
      }
    }
  }
  self.choosingPenalty = YES;
  return self;
}


static const int MISMATCH_PENALTY = 2;
static const int  MATCH_BONUS = 2;
static const int  COST_TO_CHOOSE = 1;

-(void)chooseCard:(Card *)card;
{
  NSUInteger index = [self.cards indexOfObject:card];
  [self chooseCardAtIndex:index];
}

-(void)chooseCardAtIndex:(NSUInteger)index
{
  Card *card = [self cardAtIndex:index];
  if (card.isMatched){
    return;
  }
  if (card.isChosen){
    card.chosen = NO;
    self.chosenNum --;
    return;
  }
  NSMutableArray *matchedCards = [[NSMutableArray alloc] init];
  
  // match against other cards
  for (Card *otherCard in self.cards){
    if (otherCard.isChosen && !otherCard.isMatched){
      
      [matchedCards addObject:otherCard];
      if ([matchedCards count] == self.numOfCardToMatch-1){
        break;
      }
      
    }
  }
  card.chosen = YES;
  self.chosenNum ++;
  if ([matchedCards count] == self.numOfCardToMatch-1){
    int matchScore = [card match:matchedCards];
    if (matchScore > 0){
      self.score += matchScore * MATCH_BONUS;
      for (Card *otherCard in matchedCards){
        otherCard.matched = YES;
        
      }
      card.matched = YES;
      
      
    } else {
      self.score -= MISMATCH_PENALTY;
      for (Card *otherCard in matchedCards){
        otherCard.chosen = NO;
        self.chosenNum --;
      }
      
      
    }
    
  }
  
  if (self.choosingPenalty) self.score -= COST_TO_CHOOSE;
  

}



-(Card *)cardAtIndex:(NSUInteger)index
{
  return (index < [self.cards count]) ? self.cards[index] : nil;
}

-(instancetype)init
{
  return nil;
}
@end

NS_ASSUME_NONNULL_END
