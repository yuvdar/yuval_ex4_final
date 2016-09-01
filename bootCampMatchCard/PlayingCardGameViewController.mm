// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "cardHistoryViewController.h"
@interface PlayingCardGameViewController()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *playingCardButtons;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameTypeSwitchProp;

@end

@implementation PlayingCardGameViewController
-(Deck *)createDeck
{
  return [[PlayingCardDeck alloc] init];
}


-(int)setNumberOfCardToMatch
{
  return (int)[self.gameTypeSwitchProp selectedSegmentIndex] +2;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"cardHistory"]){
    if([segue.destinationViewController isKindOfClass:[cardHistoryViewController class]]){
      cardHistoryViewController *ch = (cardHistoryViewController *)segue.destinationViewController;
      ch.textToDisplay = self.cardHistoryLog;
    }
  }
}

-(void)loadDefualtView
{
  for (UIButton *cardButton in self.playingCardButtons){
    [cardButton setTitle:@"" forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[UIImage imageNamed:@"cardBack"]  forState:UIControlStateNormal];
    cardButton.enabled = YES;
    }
}

-(NSArray *)cardButtons
{
  
  return self.playingCardButtons;
}

-(void)localReset
{
  self.gameTypeSwitchProp.enabled = YES;
  
}

-(void)localStart
{
  self.gameTypeSwitchProp.enabled = NO;
}


- (id)titleForCard:(Card *)card
{
  return card.isChosen ? card.contents : @"";
}

-(UIImage *)backgroundImageForCard:(Card *)card
{
  return [UIImage imageNamed:card.isChosen ? @"cardFront" : @"cardBack"];
}

@end



