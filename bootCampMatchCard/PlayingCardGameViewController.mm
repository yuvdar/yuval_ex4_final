// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "cardHistoryViewController.h"
#import "PlayingCardView.h"
#import "PlayingCard.h"

@interface PlayingCardGameViewController()
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameTypeSwitchProp;


@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic) IBOutletCollection(PlayingCardView) NSArray *cardViews;

@property (strong, nonatomic)  Deck *deck;

@property (strong, nonatomic) CardMatchingGame *game;

@property (nonatomic) int lastScore;

@property (strong, nonatomic) NSMutableArray *chosenCards;

@property (nonatomic) BOOL gameStarted;

@property (strong, nonatomic) NSMutableArray *cardHistory;
@property (strong, nonatomic) NSMutableAttributedString *cardHistoryLog;
@property (strong, nonatomic) NSMutableArray *scoreHistoty;

@end

@implementation PlayingCardGameViewController

#pragma  mark - view
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadDefualtView];
  
  for (PlayingCardView *currView in self.cardViews){
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe2Right:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [currView addGestureRecognizer:recognizer];
    UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe2Left:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [currView addGestureRecognizer:recognizer2];
  }
}

- (int)setNumberOfCardToMatch
{
  return (int)[self.gameTypeSwitchProp selectedSegmentIndex] +2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"cardHistory"]){
    if([segue.destinationViewController isKindOfClass:[cardHistoryViewController class]]){
      cardHistoryViewController *ch = (cardHistoryViewController *)segue.destinationViewController;
      ch.textToDisplay = self.cardHistoryLog;
    }
  }
}

- (void)loadDefualtView
{
//  [self startGame];
  for (PlayingCardView *cardButton in self.cardViews){
    cardButton.faceUp = NO;
    cardButton.disabled = NO;
    NSUInteger cardIndex = [self.cardViews indexOfObject:cardButton];
    Card *cardtemp = [self.game cardAtIndex:cardIndex];
    PlayingCard *card = (PlayingCard *)cardtemp;
    cardButton.rank = card.rank;
    cardButton.suit = card.suit;
    
    [cardButton setAlpha:1.0];
    [cardButton setNeedsDisplay];
  }
  [self updateUI];
  
}

- (NSArray *)cardButtons
{
  
  return self.cardViews;
}

- (id)titleForCard:(Card *)card
{
  return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card withCardButton:(UIButton *)cardButton
{
  return [UIImage imageNamed:card.isChosen ? @"cardFront" : @"cardBack"];
}


#pragma mark - Init methods
- (CardMatchingGame *)game
{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count] usingDeck:[self createDeck]];
  return _game;
}

- (Deck *) deck {
  if (!_deck) {
    _deck = [self createDeck];
  }
  return _deck;
}

- (Deck *)createDeck
{
  return [[PlayingCardDeck alloc] init];
}

- (NSMutableArray *)chosenCards
{
  if(!_chosenCards) _chosenCards = [[NSMutableArray alloc] init ];
  return _chosenCards;
}

#pragma mark - gestures
- (void) swipe2Right:(UISwipeGestureRecognizer *)sender
{
  [self swipe2:sender  fromDirection:UIViewAnimationOptionTransitionFlipFromLeft];
}

- (void) swipe2Left:(UISwipeGestureRecognizer *)sender
{
  [self swipe2:sender  fromDirection:UIViewAnimationOptionTransitionFlipFromRight];
}

- (void)swipe2:(UISwipeGestureRecognizer *)sender fromDirection:(UIViewAnimationOptions)direction
{
  if (!(sender.state == UIGestureRecognizerStateEnded)){
    return;
  }
  NSUInteger cardIndex = [self.cardViews indexOfObject:sender.view];
  PlayingCardView *view = (PlayingCardView *)sender.view;
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  [UIView transitionWithView:view duration:2 options:direction animations: nil
                  completion:^(BOOL fin){if (fin) {
    [self actionForCardIndex:cardIndex];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
  }
  }];
  view.faceUp = !view.faceUp;
}

#pragma mark - game functions
- (void)startGame
{
  self.game.numOfCardToMatch= [self setNumberOfCardToMatch];
  self.lastScore = 0;
  [self.chosenCards removeAllObjects];
  self.gameTypeSwitchProp.enabled = NO;
}

- (void) actionForCardIndex:(NSUInteger)cardIndex
{
  if (!self.gameStarted){
    [self startGame];
    self.gameStarted = YES;
  }
  Card *touchedCard = [self.game cardAtIndex:cardIndex];
  [self.game chooseCardAtIndex:cardIndex];
  touchedCard.isChosen ? [self.chosenCards addObject:touchedCard] : [self.chosenCards removeObject:touchedCard];
  [self updateUI];
  
}

- (void)resetChosenCards:(BOOL)resetChosen
{
  [self.chosenCards removeAllObjects];
  
  for (UIButton *cardButton in self.cardButtons){
    NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardIndex];
    if (resetChosen) {
      card.chosen = NO;
      [cardButton setBackgroundImage:[self backgroundImageForCard:card withCardButton:cardButton] forState:UIControlStateNormal];
      card.matched = NO;
    }
    if (card.isChosen && cardButton.enabled) [self.chosenCards addObject:card];
    if ([self.chosenCards count] == self.game.numOfCardToMatch){
      break;
    }
  }
  
}

- (void)disablePenalty
{
  self.game.choosingPenalty = NO;
}

#pragma mark - UI functions
- (IBAction)resetButton:(id)sender {
  // global reset:
    self.game = nil;
    [self.chosenCards removeAllObjects];
  self.cardHistory = nil;
  self.scoreHistoty = nil;
  self.cardHistoryLog = nil;
  self.gameStarted = NO;
    self.lastScore = 0;
  self.gameTypeSwitchProp.enabled = YES;

  [self updateText:[NSString stringWithFormat:@"selcet %d cards",
                    [self setNumberOfCardToMatch] ]];
  // local reset
  [self loadDefualtView];
}





- (void)updateText:(id)message
{
  if ([message isKindOfClass:[NSString class]]){
    self.textLabel.text = message;
  } else if ([message isKindOfClass:[NSAttributedString class]]){
    self.textLabel.attributedText = message;
  }
  
}

- (void)updateUI
{
  for (id cardButton in self.cardButtons){
    
    
    NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardIndex];
    if ([cardButton isKindOfClass:[UIButton class]]){
      UIButton *copyForButton = cardButton;
      id title = [self titleForCard:card];
      if ([title isKindOfClass:[NSString class]]){
        [cardButton setTitle:title forState:UIControlStateNormal];
      } else if([title isKindOfClass:[NSAttributedString class]]) {
        [cardButton setAttributedTitle:title forState:UIControlStateNormal];
      } else {
        [cardButton setTitle:@"" forState:UIControlStateNormal];
      }
      [cardButton setBackgroundImage:[self backgroundImageForCard:card withCardButton:cardButton] forState:UIControlStateNormal];
      copyForButton.enabled = !card.isMatched;
    } else if ([cardButton isKindOfClass:[PlayingCardView class]]){
      PlayingCardView *copyForButton = cardButton;
      if(copyForButton.faceUp != card.isChosen){
        [PlayingCardView transitionWithView:copyForButton duration:2.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations: nil completion: ^(BOOL fin){
          if (fin){
            copyForButton.userInteractionEnabled = !card.isMatched;
            copyForButton.disabled = card.isMatched;
          }
        }];
        copyForButton.faceUp = card.isChosen;
      } else {
        copyForButton.userInteractionEnabled = !card.isMatched;
        copyForButton.disabled = card.isMatched;
      }
      
      
    }
    
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
    [self resetChosenCards:NO];
  } else {
    if (![[chosenCardsStr string] isEqualToString:@""]){
      NSMutableAttributedString *textMessage = [[NSMutableAttributedString alloc] initWithAttributedString:chosenCardsStr];
      NSMutableAttributedString *lineEnd = [[NSMutableAttributedString alloc] initWithString:
                                            [NSString stringWithFormat:@" selected.\n selcet %d more",                                                                                              (int)self.game.numOfCardToMatch - (int)[self.chosenCards count]]] ;
      [textMessage appendAttributedString:lineEnd];
      [self updateText:textMessage];
    } else {
      [self updateText:[NSString stringWithFormat:@"selcet %d cards",
                        (int)self.game.numOfCardToMatch ]];
    }
  }
}

- (NSMutableAttributedString *)stringForChosenCards:(NSArray *)chosenCards
{
  NSString *temp  = @"";
  for (Card *cCard in chosenCards){
    temp = [NSString stringWithFormat:@"%@ %@", temp, cCard.contents];
  }
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
  
  return str;
}

#pragma mark - card history
- (NSMutableArray *)cardHistory
{
  if(!_cardHistory) _cardHistory = [[NSMutableArray alloc] init];
  return _cardHistory;
}
- (NSMutableAttributedString *)cardHistoryLog
{
  if(!_cardHistoryLog) _cardHistoryLog = [[NSMutableAttributedString alloc] initWithString:@""];
  return _cardHistoryLog;
}

- (NSMutableArray *)scoreHistoty
{
  if(!_scoreHistoty) _scoreHistoty = [[NSMutableArray alloc] init];
  return _scoreHistoty;
}

- (void)updateHIstoryLog:(NSMutableAttributedString *)chosenCardsStr withCardsArray:(NSArray *)cards withScore:(int)scoreChange
{
  [self.cardHistory addObject:[cards copy]];
  [self.scoreHistoty addObject:[NSNumber numberWithInteger:scoreChange]];
  NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:chosenCardsStr];
  [self.cardHistoryLog appendAttributedString:log];
  NSAttributedString *nextLine  = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" points:%d\n", scoreChange]];
  [self.cardHistoryLog appendAttributedString:nextLine];
}

@end



