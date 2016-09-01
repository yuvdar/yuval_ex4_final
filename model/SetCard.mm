// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "SetCard.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SetCard

-(int)match:(NSArray *)otherCards
{
  
  if ([otherCards count] != 2){
    return 0;
  }
  SetCard *firstCard = [otherCards firstObject];
  SetCard *secondCard = [otherCards lastObject];
  // check suit
  if (!([firstCard.suit isEqual:self.suit] == [secondCard.suit isEqual:self.suit])) {
    NSLog(@"suit dont match %@-%@-%@",firstCard.suit,secondCard.suit, self.suit);
    return 0;
  }
  if (!([firstCard.suit isEqual:self.suit] == [secondCard.suit isEqual:firstCard.suit])){
    NSLog(@"suit dont match %@-%@-%@",firstCard.suit,secondCard.suit, self.suit);
    return 0;
  }
  // check rank
  if (!((firstCard.rank  == self.rank) == (secondCard.rank == self.rank))) {
    NSLog(@"rank dont match %d-%d-%d",(int)firstCard.rank,(int)secondCard.rank, (int)self.rank);
    return 0;
  }
  if (!((firstCard.rank == self.rank) == (secondCard.rank == firstCard.rank))){
    NSLog(@"rank dont match %d-%d-%d",(int)firstCard.rank,(int)secondCard.rank, (int)self.rank);
    return 0;
  }
  // check color
  if (!([firstCard.color isEqual:self.color] == [secondCard.color isEqual:self.color])) {
    NSLog(@"color dont match %@-%@-%@",firstCard.color,secondCard.color, self.color);

    return 0;
  }
  if (!([firstCard.color isEqual:self.color] == [secondCard.color isEqual:firstCard.color])){
    NSLog(@"color dont match %@-%@-%@",firstCard.color,secondCard.color, self.color);
    return 0;
  }
  // check suit
  if (!([firstCard.shading isEqual:self.shading] == [secondCard.shading isEqual:self.shading])) {
    NSLog(@"shading dont match %@-%@-%@",firstCard.shading,secondCard.shading, self.shading);

    return 0;
  }
  if (!([firstCard.shading isEqual:self.shading] == [secondCard.shading isEqual:firstCard.shading])){
    NSLog(@"shading dont match %@-%@-%@",firstCard.shading,secondCard.shading, self.shading);

    return 0;
  }
  
  return 1;
}

+ (NSArray *)validSuits
{
  return @[@"■",@"●",@"▲"];
}
+ (NSArray *)validRanks
{
  return @[@"1",@"2",@"3"];
}
+(NSArray *)validColors
{
  return @[@"redColor", @"blackColor", @"blueColor"];
}


+(NSArray *)validfill
{
  return @[@"open", @"striped", @"solid"];
}


+(NSUInteger) maxRank
{
  return [[self validRanks] count];
}


@end

NS_ASSUME_NONNULL_END
