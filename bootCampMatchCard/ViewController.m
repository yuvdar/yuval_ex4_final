//
//  ViewController.m
//  bootCampMatchCard
//
//  Created by Yuval Dar on 8/24/16.
//  Copyright © 2016 Yuval Dar. All rights reserved.
//

#import "ViewController.h"
#import "Card.h"

@interface ViewController ()

//@property (weak, nonatomic) IBOutlet UILabel *numOfFlips;
//@property (nonatomic) int flipCount;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *gameTypeSwitchProp;

@property (strong, nonatomic) NSMutableArray *chosenCards;
@property (nonatomic) int lastScore;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic)  Deck *deck;
@property (nonatomic, strong) CardMatchingGame *game;

@property (nonatomic)  BOOL done;
@end

@implementation ViewController



- (Deck *) deck {
  if (!_deck) {
    _deck = [self createDeck];
  }
  return _deck;
}


-(NSArray *)cardButtons
{
  NSLog(@"problem with cardButtons?");
  return nil;
}

- (Deck *) createDeck // abstract
{
  NSLog(@"problem with init?");
  return nil;
}
-(void)localStart
{
  
}
-(void)localReset
{
  
}





-(void)loadDefualtView
{
  
}


- (CardMatchingGame *)game{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count] usingDeck:[self createDeck]];
  return _game;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadDefualtView];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (id)titleForCard:(Card *)card
{
  return nil;
}

-(int)setNumberOfCardToMatch
{
  return 0;
}


-(NSMutableAttributedString *)stringForChosenCards:(NSArray *)chosenCards
{
  NSString *temp  = @"";
  for (Card *cCard in chosenCards){
    temp = [NSString stringWithFormat:@"%@ %@", temp, cCard.contents];
  }
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
  
  return str;
}

-(void)startGame
{
  self.game.numOfCardToMatch= [self setNumberOfCardToMatch]; //
  self.lastScore = 0;
  [self.chosenCards removeAllObjects];
  [self localStart];
}



-(NSAttributedString *)checkIfLegal:(Card *)card whenChosenCardsAre:chosenCards
{
  return nil;
}

-(IBAction)touchCardButton:(UIButton *)sender
{
  if (!self.gameStarted){
    [self startGame];
    self.gameStarted = YES;
  }
  NSUInteger cardIndex = [self.cardButtons indexOfObject:sender];
  Card *touchedCard = [self.game cardAtIndex:cardIndex];
  NSAttributedString *errorMessage = [self checkIfLegal:touchedCard whenChosenCardsAre:self.chosenCards];
  if (!errorMessage) {
    [self.game chooseCardAtIndex:cardIndex];
    touchedCard.isChosen ? [self.chosenCards addObject:touchedCard] : [self.chosenCards removeObject:touchedCard];
    [self updateUI];
  } else {
    [self updateText:errorMessage];
    [self resetChosenCards:self.keepButtonEnanled];
  }
}

-(void)updateText:(id)message
{
  if ([message isKindOfClass:[NSString class]]){
    self.textLabel.text = message;
  } else if ([message isKindOfClass:[NSAttributedString class]]){
    self.textLabel.attributedText = message;
  }
  
}
-(NSMutableArray *)chosenCards
{
  if(!_chosenCards) _chosenCards = [[NSMutableArray alloc] init ];
  return _chosenCards;
}



-(void)disablePenalty
{
  self.game.choosingPenalty = NO;
}


-(void)resetChosenCards:(BOOL)resetChosen
{
  [self.chosenCards removeAllObjects];

  for (UIButton *cardButton in self.cardButtons){
    NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardIndex];
    if (resetChosen) {
      card.chosen = NO;
      card.matched = NO;
    }
    if (card.isChosen && cardButton.enabled) [self.chosenCards addObject:card];
    if ([self.chosenCards count] == self.game.numOfCardToMatch){
      break;
    }
  }

}
-(NSMutableArray *)cardHistory
{
  if(!_cardHistory) _cardHistory = [[NSMutableArray alloc] init];
  return _cardHistory;
}
-(NSMutableAttributedString *)cardHistoryLog
{
  if(!_cardHistoryLog) _cardHistoryLog = [[NSMutableAttributedString alloc] initWithString:@""];
  return _cardHistoryLog;
}
-(NSMutableArray *)scoreHistoty
{
  if(!_scoreHistoty) _scoreHistoty = [[NSMutableArray alloc] init];
  return _scoreHistoty;
}



-(void)updateHIstoryLog:(NSMutableAttributedString *)chosenCardsStr withCardsArray:(NSArray *)cards withScore:(int)scoreChange
{
  [self.cardHistory addObject:[cards copy]];
  [self.scoreHistoty addObject:[NSNumber numberWithInteger:scoreChange]];
  NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:chosenCardsStr];
  [self.cardHistoryLog appendAttributedString:log];
  NSAttributedString *nextLine  = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" points:%d\n", scoreChange]];
  [self.cardHistoryLog appendAttributedString:nextLine];
}

- (void)updateUI
{
  for (UIButton *cardButton in self.cardButtons){
    NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardIndex];
    id title = [self titleForCard:card];
    if ([title isKindOfClass:[NSString class]]){
      [cardButton setTitle:title forState:UIControlStateNormal];
    } else if([title isKindOfClass:[NSAttributedString class]]) {
      [cardButton setAttributedTitle:title forState:UIControlStateNormal];
    } else {
      [cardButton setTitle:@"" forState:UIControlStateNormal];
    }
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
    if (!self.keepButtonEnanled) cardButton.enabled = !card.isMatched;
  }
  
  int scoreChange = (int)self.game.score - self.lastScore;
  self.lastScore = (int)self.game.score;
  
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", (int)self.game.score];
  
  
  NSMutableAttributedString *chosenCardsStr = [self stringForChosenCards:self.chosenCards];

  
  if ([self.chosenCards count] == (int)self.game.numOfCardToMatch){
    if (scoreChange>0){
      NSMutableAttributedString *textMessage = [[NSMutableAttributedString alloc] initWithString:@"GREAT! "];
      NSMutableAttributedString *lineEnd = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" are matched!\n %d points added" , scoreChange]] ;
      [textMessage appendAttributedString:chosenCardsStr];
      [textMessage appendAttributedString:lineEnd];
      [self updateText:textMessage];
      
    } else if (scoreChange < 0 ){
      NSMutableAttributedString *textMessage = [[NSMutableAttributedString alloc] initWithAttributedString:chosenCardsStr];;
      NSMutableAttributedString *lineEnd = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" are no matched.. :(\n %d points lost" , scoreChange]] ;
      [textMessage appendAttributedString:lineEnd];
      [self updateText:textMessage];

    }

    [self updateHIstoryLog:chosenCardsStr withCardsArray:self.chosenCards withScore:scoreChange];

    [self resetChosenCards:self.keepButtonEnanled];
  } else {
    if (![[chosenCardsStr string] isEqualToString:@""]){
      NSMutableAttributedString *textMessage = [[NSMutableAttributedString alloc] initWithAttributedString:chosenCardsStr];
      NSMutableAttributedString *lineEnd = [[NSMutableAttributedString alloc] initWithString:[NSString
                                                                                              stringWithFormat:@" selected.\n selcet %d more",
                                                                                              (int)self.game.numOfCardToMatch - (int)[self.chosenCards count]]] ;
      [textMessage appendAttributedString:lineEnd];
      [self updateText:textMessage];
      
      

    } else {
      [self updateText:[NSString stringWithFormat:@"selcet %d cards",
                        (int)self.game.numOfCardToMatch ]];
    }
  }
}



-(UIImage *)backgroundImageForCard:(Card *)card
{
  return [UIImage imageNamed:@"cardFront"];
}


- (IBAction)changeGameType:(UISegmentedControl *)sender {
  [self updateText:[NSString stringWithFormat:@"selcet %d cards",
                    [self setNumberOfCardToMatch]  ]];
}



- (IBAction)resetButton:(UIButton *)sender {
  // global reset:
  self.game = nil;
  [self.chosenCards removeAllObjects];
  self.cardHistory = nil;
  self.scoreHistoty = nil;
  self.cardHistoryLog = nil;
  self.gameStarted = NO;
  [self updateText:[NSString stringWithFormat:@"selcet %d cards",
                    [self setNumberOfCardToMatch] ]];
  // local reset
  [self loadDefualtView];
  [self localReset];

}



@end
