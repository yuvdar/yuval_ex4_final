//
//  ViewController.h
//  bootCampMatchCard
//
//  Created by Yuval Dar on 8/24/16.
//  Copyright © 2016 Yuval Dar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "CardMatchingGame.h"

@interface ViewController : UIViewController

@property (strong, nonatomic)  NSArray *cardButton;
@property (nonatomic) BOOL gameStarted;
@property (nonatomic) BOOL keepButtonEnanled;
@property (strong, nonatomic) NSMutableArray *cardHistory;
@property (strong, nonatomic) NSMutableAttributedString *cardHistoryLog;
@property (strong, nonatomic) NSMutableArray *scoreHistoty;


- (Deck *) createDeck; // abstract 
-(int)setNumberOfCardToMatch; //abstract
-(void)localReset; //abstract
-(void)localStart; //abstract
-(id)titleForCard:(Card *)card; //abstract
-(UIImage *)backgroundImageForCard:(Card *)card; // abstract
-(void)loadDefualtView; // abstract
-(NSMutableAttributedString *)stringForChosenCards:(NSArray *)chosenCards;
-(NSAttributedString *)checkIfLegal:(Card *)card whenChosenCardsAre:chosenCards;
-(void)startGame;
- (void)updateUI;
-(void)disablePenalty;

@end
