// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "SetCardGameViewController.h"
//#import "PlayingCardDeck.h"

#import "SetCardDeck.h"
#import "SetCard.h"
#import "cardHistoryViewController.h"

@interface SetCardGameViewController()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *SetGameButtin;

@end

@implementation SetCardGameViewController




-(Deck *)createDeck
{
//  return [[PlayingCardDeck alloc] init];

  return [[SetCardDeck alloc] init];
}


-(NSArray *)cardButtons
{
  return self.SetGameButtin;
}

-(void)loadDefualtView
{
  if (!(self.gameStarted)){
    [self startGame];
    self.gameStarted = YES;
  }
  [self updateUI];
  [self disablePenalty];
  self.keepButtonEnanled = YES;
}

-(int)setNumberOfCardToMatch
{
  return 3;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"setHistory"]){
    if([segue.destinationViewController isKindOfClass:[cardHistoryViewController class]]){
      cardHistoryViewController *ch = (cardHistoryViewController *)segue.destinationViewController;
      ch.textToDisplay = self.cardHistoryLog;
    }
  }
}

+(id)cardTitle:(Card *)card
{
  if (!([card isKindOfClass:[SetCard class]])){
    return nil;
  }
  SetCard *sCard = card;
  NSDictionary *colorDict = @{@"blueColor" : [UIColor blueColor], @"redColor" : [UIColor redColor], @"blackColor" : [UIColor blackColor]};
  NSDictionary *fillLevel = @{@"open" : [NSNumber numberWithFloat:0.0], @"striped" : [NSNumber numberWithFloat:0.3], @"solid" : [NSNumber numberWithFloat:1.0]};
  NSNumber *shade = fillLevel[sCard.shading];
  NSString *ret  = @"";
  for (int i=0; i<sCard.rank; i++){
    ret = [ret stringByAppendingString:sCard.suit];
  }
  UIColor *color = [colorDict[sCard.color] colorWithAlphaComponent:[shade floatValue]];
  NSMutableAttributedString *ttl = [[NSMutableAttributedString alloc] initWithString:ret];
  
  [ttl addAttributes:@{NSForegroundColorAttributeName: color,
                       NSStrokeWidthAttributeName: @-8,
                       NSStrokeColorAttributeName: colorDict[sCard.color]}
               range:NSMakeRange(0, sCard.rank)];
  return ttl;
}


-(NSMutableAttributedString *)stringForChosenCards:(NSArray *)chosenCards
{
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@""];
  for (Card *cCard in chosenCards){
    [str appendAttributedString:[SetCardGameViewController cardTitle:cCard]];
    [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@", "]];
  
  }
  
  
  return str;
}


- (id)titleForCard:(Card *)card
{
  return  [SetCardGameViewController cardTitle:card];
}

-(UIImage *)backgroundImageForCard:(Card *)card
{
  return [UIImage imageNamed:@"cardFront"];
}


-(BOOL)checkCardSet:(NSArray *)cardSets equalTo:(NSArray *)currentCards
{
  int numOfMatches = 0;
  NSMutableArray *first = [cardSets mutableCopy];
  NSMutableArray *second = [currentCards mutableCopy];
  for (SetCard *card1 in first){
    for(SetCard *card2 in second){
      if ([card1 isEqual:card2]){
        numOfMatches++;
        [second removeObject:card2];
        break;
      }
    }
    if (numOfMatches != [first indexOfObject:card1]+1){
      return NO;
    }
  }
  return numOfMatches == 3;
}

-(NSAttributedString *)checkIfLegal:(Card *)card whenChosenCardsAre:(NSArray *)chosenCards
{
  if ([chosenCards count] != 2){
    return nil;
  }
  NSMutableArray *currentCards = [chosenCards mutableCopy];
  [currentCards addObject:card];
  BOOL notLegal = NO;
  for (int i=0; i<[self.cardHistory count]; i++){
    if ([self.scoreHistoty[i] integerValue]<0){
      continue;
    }
    NSArray *cardSets =self.cardHistory[i];
    notLegal = [self checkCardSet:cardSets equalTo:currentCards];
    if (notLegal) break;
  }
  if (!notLegal){
    return nil;
  }
  NSMutableAttributedString *msg = [self stringForChosenCards:(NSArray *)currentCards];
  [msg appendAttributedString:[[NSAttributedString alloc] initWithString:@" was already chosen\n"]];
  return msg;
  
}

@end

