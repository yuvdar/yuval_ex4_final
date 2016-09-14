//
//  ViewController.h
//  bootCampMatchCard
//
//  Created by Yuval Dar on 8/24/16.
//  Copyright © 2016 Yuval Dar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Card.h"
#import "CardMatchingGame.h"

@interface ViewController : UIViewController

@property (strong, nonatomic)  NSArray *cardButton;
@property (nonatomic) BOOL gameStarted;


@property (strong, nonatomic) NSMutableArray *cardHistory;
@property (strong, nonatomic) NSMutableAttributedString *cardHistoryLog;
@property (strong, nonatomic) NSMutableArray *scoreHistoty;
//@property (strong, nonatomic) CardMatchingGame *game;

- (Deck *) createDeck; // abstract 
- (int)setNumberOfCardToMatch; //abstract
- (id)titleForCard:(Card *)card; //abstract
- (UIImage *)backgroundImageForCard:(Card *)card withCardButton:(UIButton *)cardButton; // abstract
- (void)loadDefualtView; // abstract
- (NSMutableAttributedString *)stringForChosenCards:(NSArray *)chosenCards;
- (NSAttributedString *)checkIfLegal:(Card *)card whenChosenCardsAre:chosenCards;
- (void) actionForCardIndex:(NSUInteger)cardIndex;
- (void)startGame;
- (void)updateUI;



// to delete:
- (void)localReset; //abstract
- (void)localStart; //abstract
- (void)disablePenalty;

@end
