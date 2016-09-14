// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "setCardDisplayViewController.h"
#import "setCardVIew.h"
#import "SetCard.h"
#import "setCardDeck.h"
#import "CardMatchingGame.h"
#import "Grid.h"
#import "cardControllerProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface setCardDisplayViewController() <UIDynamicAnimatorDelegate, cardControllerProtocol>


@property (weak, nonatomic) UILabel *scoreLabel;

@property (strong, nonatomic) IBOutlet UIView *gameView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *re_arrangeControl;

@property (weak, nonatomic) IBOutlet UIButton *dealCardButton;

@property (strong, nonatomic) Grid *grid;

@property (strong, nonatomic) NSMutableArray *cardAllocation;

@property (strong, nonatomic) NSMutableArray *viewAllocation;

@property (nonatomic) NSUInteger nextCardIndex;

@property (nonatomic) NSUInteger numOfCardsInDisplay;

@property (weak, nonatomic) SetCard *movingCard;
@property (nonatomic) CGRect originalLocation;
@property (strong, nonatomic) SetCardVIew *collectionCardsView;


// move to protocol:







@end

@implementation setCardDisplayViewController

@synthesize deck = _deck;
@synthesize game = _game;
@synthesize lastScore = _lastScore;
@synthesize chosenCards = _chosenCards;

-(void)viewDidLoad
{
  [super viewDidLoad];
  [self game];
  [self scoreLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.gameView setNeedsDisplay];
  UIPinchGestureRecognizer *recognizer;
  recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(collectCards:)];
  [self.gameView addGestureRecognizer:recognizer];

}

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self.gameView setNeedsDisplay];
}

- (void) traitCollectionDidChange: (UITraitCollection * _Nullable) previousTraitCollection {
  [super traitCollectionDidChange: previousTraitCollection];
  if ((self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass)
      || self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass) {
    NSUInteger prev = [self.re_arrangeControl selectedSegmentIndex];
    [self.re_arrangeControl setSelectedSegmentIndex:1];
    if (self.numOfCardsInDisplay > 0){
      [self re_arangeGrid:(int)self.numOfCardsInDisplay];
    }
    [self.re_arrangeControl setSelectedSegmentIndex:prev];
    CGFloat bottom = [[[self tabBarController] tabBar] bounds].size.height;
  
    self.scoreLabel.frame =  CGRectMake(self.gameView.bounds.origin.x + 8,
                                       self.gameView.bounds.size.height - bottom -
                                        self.scoreLabel.intrinsicContentSize.height - 8,
                                   self.scoreLabel.intrinsicContentSize.width,
                                   self.scoreLabel.intrinsicContentSize.height);
  }
}

#define STARTING_CARD_NUMBER 12
#define MIN_CARD_WIDTH 60
#define NUMBER_OF_CARDS_TO_MATCH 3
#define DEALING_CARD_NUMBER 3

# pragma mark - init methods
- (Deck *) deck {
  if (!_deck) {
    _deck = [self createDeck];
  }
  return _deck;
}

- (Deck *) createDeck
{
  return [[SetCardDeck alloc] init];
}

- (Grid *) grid {
  if (!_grid) {
    _grid = [ self gridReAlloc:STARTING_CARD_NUMBER];
  }
  return _grid;
}


- (Grid *) gridReAlloc:(int)Capacity
{
  Grid *newGrid = [[Grid alloc] init];
  newGrid.cellAspectRatio = 3.0 / 2.0;
  CGFloat factor = (self.gameView.bounds.size.height - 150 )/ self.gameView.bounds.size.height;
  newGrid.size = CGSizeMake(self.gameView.bounds.size.width*7/8
                          , self.gameView.bounds.size.height*factor);
  newGrid.minimumNumberOfCells = Capacity;
  newGrid.minCellHeight = MIN_CARD_WIDTH;
  while (!newGrid.inputsAreValid && newGrid.minCellHeight > 0)
  {
    newGrid.minCellHeight -= 5;
  }
  assert(newGrid.inputsAreValid);
  
  return newGrid;
}

- (NSMutableArray *)cardAllocation
{
  if (!_cardAllocation) {
    _cardAllocation = [setCardDisplayViewController cardArrayFromGrid:_grid];
  }
  return _cardAllocation;
}

+ (NSMutableArray *)cardArrayFromGrid:(Grid *)grid
{
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  NSMutableArray *col = [[NSMutableArray alloc] init];
  for (int j=0; j<grid.columnCount; j++)
  {
    [col addObject:[NSNull null]];
  }
  for (int i=0; i<grid.rowCount; i++)
  {
    [arr addObject:[col mutableCopy]];
  }
  return arr;
}
- (NSMutableArray *)viewAllocation
{
  if (!_viewAllocation) {
    _viewAllocation = [[NSMutableArray alloc] init];
  }
  return _viewAllocation;
}

- (NSMutableArray *)chosenCards
{
  if (!_chosenCards) _chosenCards = [[NSMutableArray alloc] initWithCapacity:[self.game numOfCardToMatch]];
  return _chosenCards;
}

- (UILabel *  _Nullable )scoreLabel
{
  if(!_scoreLabel) {
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", (int)self.game.score];

    [self.gameView addSubview:scoreLabel];
    
    _scoreLabel = scoreLabel;
  }
  return _scoreLabel;
}



#pragma mark - gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return NO;
}
- (void)addSwipeGestureToView:(SetCardVIew *)currView
{
  UISwipeGestureRecognizer *recognizer;
  recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionForSwipe:fromDirection:)];
  [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
  [currView addGestureRecognizer:recognizer];
  recognizer.delegate =  (id)self;
  recognizer = nil;
  recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionForSwipe:fromDirection:)];
  [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
  [currView addGestureRecognizer:recognizer];
  recognizer.delegate =  (id)self;
}

- (void)addPanGestureToView:(SetCardVIew *)currView
{
  UIPanGestureRecognizer *recognizer;
  recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCards:)];
  recognizer.delegate =  (id)self;
  for (id prev_recognizer in currView.gestureRecognizers){
    if ([prev_recognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
      [recognizer requireGestureRecognizerToFail:prev_recognizer];
    }
  }
  [currView addGestureRecognizer:recognizer];
}



- (void)actionForSwipe:(UISwipeGestureRecognizer *)sender fromDirection:(UIViewAnimationOptions)direction
{
  SetCard *card = [self cardFromView:(SetCardVIew *)sender.view];
  [self actionForCard:card];
  NSLog(@"%@", card);
}

- (IBAction)deal:(UIButton *)sender {
  NSArray *deltCards = [self loadCardsToArray:DEALING_CARD_NUMBER];
  [self loadCardsToView:deltCards];
  
}



- (IBAction)newGame:(UIButton *)sender {
  [self startGame];
}



#pragma mark - animation

- (void)collectCards:(UIPinchGestureRecognizer *)sender
{
  if (! (sender.state == UIGestureRecognizerStateEnded)) {
    return;
  }
  if (self.collectionCardsView.superview){
    return;
  }
  if ([_viewAllocation count] == 0){
    return;
  }
  SetCardVIew *tempView = [_viewAllocation lastObject];
  
  CGSize cardSize = tempView.bounds.size;
  
  CGRect collection = CGRectMake(self.gameView.center.x - cardSize.width/2,
                                 self.gameView.center.y - cardSize.height/2,
                                 cardSize.width, cardSize.height);
  SetCard *card = [self cardFromView:tempView];
  SetCardVIew *collectedCards = [self viewWithFrame:collection andCard:card atRow:-1 inColumn:-1];
  [collectedCards setUserInteractionEnabled:NO];
  [collectedCards setHidden:YES];
  [self.gameView addSubview:collectedCards];
  self.collectionCardsView = collectedCards;
  double animaDuration = 1.0;
  for (SetCardVIew *view in _viewAllocation){
    CGRect originalRect = view.frame;
    [UIView animateWithDuration:animaDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       view.frame = collection;
                     } completion:^(BOOL finished){
                       if (finished){
                        [collectedCards setHidden:NO];
                         [view setUserInteractionEnabled:NO];
                         [view setHidden:YES];
                         view.frame = originalRect;
   
                       }
                     }];
  }
  

  [collectedCards setUserInteractionEnabled:YES];
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]  initWithTarget:self action:@selector(moveCardsFreely:)];
  [collectedCards addGestureRecognizer:pan];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(spreadCards:)];
  [collectedCards addGestureRecognizer:tap];
  self.dealCardButton.enabled = NO;
}

- (void)spreadCards:(UITapGestureRecognizer *)sender
{
  BOOL first = YES;
  for (SetCardVIew *view in _viewAllocation){
    CGRect targetFrame = view.frame;
    view.frame = sender.view.frame;
    [view setHidden:NO];
    if (first){
      [sender.view removeFromSuperview];
      first = NO;
    }
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       view.frame = targetFrame;
                     } completion:^(BOOL finished){
                       if (finished){
                         [view setUserInteractionEnabled:YES];
                       }
                     }];
  }
  self.dealCardButton.enabled = YES;
  [self updateUI];
}

- (void)moveView:(SetCardVIew *) view toFrame:(CGRect)newFrame inGrid:(Grid *)grid
{
  [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     view.frame = [self fixFrame:newFrame withGrid:grid];
                   } completion:^(BOOL finished){}];
  
}

- (void)moveCards:(UIPanGestureRecognizer *)sender
{
  
  CGPoint translate = [sender translationInView:self.gameView];
  CGPoint gesturePoint = CGPointMake(sender.view.frame.origin.x + sender.view.frame.size.width/2.0,
                                     sender.view.frame.origin.y + sender.view.frame.size.height/2.0);
  
  if (sender.state == UIGestureRecognizerStateBegan) {
   
    int CardRow, CardCol;
    BOOL found = [self findClosestCard:gesturePoint retunrRow:CardRow returnCol:CardCol];
    if (!found){
      return;
    }
    [self markCardToUpdateRow:CardRow inColumn:CardCol];
    self.originalLocation = [self fixFrame:[self.grid frameOfCellAtRow:CardRow inColumn:CardCol]];
    
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    [UIView animateWithDuration:0.03 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
      sender.view.center = CGPointMake(sender.view.center.x + translate.x,
                                       sender.view.center.y + translate.y);
      [sender setTranslation:CGPointZero inView:self.gameView];
         }                     completion:^(BOOL finished){}];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    int row, col;
    CGRect endFrame = self.originalLocation;
    BOOL found = [self findClosestCard:gesturePoint retunrRow:row returnCol:col];
    if (found){
      if ([self isLocationEmpty:row inColumn:col]){
        int CardRow, CardCol;
        CGPoint originalCenter = CGPointMake(self.originalLocation.origin.x + self.originalLocation.size.width/2,
                                             self.originalLocation.origin.y + self.originalLocation.size.height/2);
        BOOL found = [self findClosestCard:originalCenter retunrRow:CardRow returnCol:CardCol];
        assert (found);
        _cardAllocation[CardRow][CardCol] = [NSNull null];
        _cardAllocation[row][col] = self.movingCard;
        SetCardVIew *view = (SetCardVIew *)sender.view;
        view.rowIndex = row; view.colIndex = col;
        
        self.movingCard = nil;
        endFrame = [self fixFrame:[self.grid frameOfCellAtRow:row inColumn:col]];
      }
    }
    [UIView animateWithDuration:1.0 animations:^{
      sender.view.frame = endFrame;
    }];
  }
  
}

- (void)moveCardsFreely:(UIPanGestureRecognizer *)sender
{
  
  CGPoint translate = [sender translationInView:self.gameView];

  if (sender.state == UIGestureRecognizerStateBegan) {
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    [UIView animateWithDuration:0.03 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       sender.view.center = CGPointMake(sender.view.center.x + translate.x,
                                                        sender.view.center.y + translate.y);
                       [sender setTranslation:CGPointZero inView:self.gameView];
                     }                     completion:^(BOOL finished){}];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    

  }
  
}




#pragma mark - display

- (void)updateUI
{
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", (int)self.game.score];
  [self.scoreLabel sizeToFit];
  for (SetCardVIew *view in [self.viewAllocation mutableCopy]){
    SetCard *card = [self cardFromView:view];
    if ([card isEqual:[NSNull null]]){
      return;
    }
    [view setAlpha:card.isChosen ? 0.5 : 1.0];
    if (card.isMatched){
      [self cleanRemoveView:view withCard:card] ;
    }
  }
//  [self re_arangeGrid:(int)self.numOfCardsInDisplay];
  [self.gameView setNeedsDisplay];
}


- (void)re_arangeGrid:(int)newCapacity
{
  if ([self.re_arrangeControl selectedSegmentIndex] == 0){
    return;
  }
  
  Grid *tempGrid = [self gridReAlloc:newCapacity];
  
  if (tempGrid.rowCount == _grid.rowCount && tempGrid.columnCount == (int)_grid.columnCount){
    return;
  }
  NSMutableArray *tempCardArray  = [setCardDisplayViewController cardArrayFromGrid:tempGrid];
  int viewItr = 0;
  for (int i=0; i<tempGrid.rowCount; i++){
    for (int j=0; j<tempGrid.columnCount; j++){
      SetCardVIew *view = _viewAllocation[viewItr];
      SetCard *card = [self cardFromView:view];
      tempCardArray[i][j] = card;
      [self moveView:view toFrame:[tempGrid frameOfCellAtRow:i inColumn:j] inGrid:tempGrid];
      view.rowIndex =i; view.colIndex = j;
      viewItr++;
      if (viewItr == [_viewAllocation count]) break;
    }
    if (viewItr == [_viewAllocation count]) break;
  }
    _grid = tempGrid;
  _cardAllocation = tempCardArray;
}



- (void)cleanRemoveView:(SetCardVIew *)view withCard:(SetCard *)card
{
  CGRect cornerRect = CGRectMake(self.gameView.bounds.size.width - view.bounds.size.width,
                                 self.gameView.bounds.size.height - view.bounds.size.height,
                                 view.bounds.size.width, view.bounds.size.height);
  [UIView animateWithDuration:1.0 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
    view.frame = cornerRect;
  } completion:^(BOOL finished){}];
  self.numOfCardsInDisplay --;
  [UIView animateWithDuration:1.0 delay:1.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
    [view setAlpha:0];
  } completion:^(BOOL finished){if (finished) {
    [view removeFromSuperview];
    [self re_arangeGrid:(int)self.numOfCardsInDisplay];
  }
}];
  
  [self.viewAllocation removeObject:view];
  assert ([card isEqual: _cardAllocation[view.rowIndex][view.colIndex]]);
   _cardAllocation[view.rowIndex][view.colIndex]= [NSNull null];
}

- (SetCardVIew *)viewWithFrame:(CGRect)frame andCard:(SetCard *)card atRow:(int)row inColumn:(int)col
{
  SetCardVIew *view = [[SetCardVIew alloc] initWithFrame:frame];
  
  view.suit = card.suit;
  view.rank = card.rank;
  view.shading = card.shading;
  view.color = card.color;
  view.rowIndex = row;
  view.colIndex = col;
  return view;
}


- (CGPoint)fixOrigin:(CGPoint)origin withGrid:(Grid *)grid
{
  origin.y +=  grid.cellSize.height/3.0;
  origin.x +=  (self.gameView.bounds.size.width -  grid.cellSize.width*grid.columnCount)/2.0;
  return origin;
}

- (CGPoint)fixOrigin:(CGPoint)origin
{
  origin = [self fixOrigin:origin withGrid:_grid];
  return origin;
}


- (CGRect)fixFrame:(CGRect)frame
{
  frame = [self fixFrame:frame withGrid:_grid];
  return frame;
}

- (CGRect)fixFrame:(CGRect)frame withGrid:(Grid *)grid
{
  frame = CGRectInset(frame, frame.size.width*0.1, frame.size.height*0.1);
  frame.origin = [self fixOrigin:frame.origin withGrid:grid];
  return frame;
}



- (void)addCardDisplay:(SetCard *)card AtRow:(int)row inColumn:(int)col
{
  CGRect frame = [self fixFrame:[self.grid frameOfCellAtRow:row inColumn:col] ];
  
  CGRect cornerRect =CGRectMake(self.gameView.bounds.size.width,
                                self.gameView.bounds.size.height,
                                frame.size.width, frame.size.height);
  SetCardVIew *cardView = [self viewWithFrame:cornerRect andCard:card atRow:row inColumn:col];
  [cardView setAlpha:0];
  [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
    [cardView setAlpha:1];
    cardView.frame = frame;
  
    
  } completion:^(BOOL finished){
  
   
  
  }];
  [self.viewAllocation addObject:cardView];
  
  [self addSwipeGestureToView:cardView];
  [self addPanGestureToView:cardView];
  
  [self.gameView addSubview:cardView];
  
  [self.gameView setNeedsDisplay];
  
  
  
  

 
  
}


- (BOOL)isLocationEmpty:(int)row inColumn:(int)col
{
  return [self.cardAllocation[row][col] isEqual:[NSNull null]];
}

- (void)changeLocation:(int)row inColumn:(int)col toState:(id)state
{
  [[self.cardAllocation objectAtIndex:row] replaceObjectAtIndex:col withObject:state];
  
}

- (void)loadCardsToView:(NSArray *)newCardsArry
{
  int numOfCards = (int)[newCardsArry count];
  int newCapacity = (int)self.numOfCardsInDisplay + numOfCards;
  
  if (newCapacity > [SetCard fullDeckSize]){
    newCapacity = (int)[SetCard fullDeckSize];
  }
  if (_grid){
    [self re_arangeGrid:newCapacity];
  }
  Grid *useGrid = [self grid];
  
  int addedCards = 0;
  if (self.nextCardIndex >= [SetCard fullDeckSize]){
    [self noMoreCards:@"DECK IS EMPTY"];
    self.dealCardButton.enabled = NO;
    return;
  }
  if (self.numOfCardsInDisplay == useGrid.columnCount * useGrid.rowCount){
    [self noMoreCards:@"NO ROOM FOR MORE CARDS"];
    return;
  }
  for (int i=0; i<useGrid.rowCount; i++)
  {
    for (int j=0; j<useGrid.columnCount; j++)
    {
      if ([self isLocationEmpty:i inColumn:j]){
        SetCard *card2add = [newCardsArry objectAtIndex:addedCards];
        [self addCardDisplay:card2add AtRow:i inColumn:j];
        [self changeLocation:i inColumn:j toState:card2add];
        addedCards ++;
        self.numOfCardsInDisplay ++;
        if (self.numOfCardsInDisplay > useGrid.columnCount * useGrid.rowCount){
          [self noMoreCards:@"NO ROOM FOR MORE CARDS"];
          return;
        }
      }
      if (addedCards == numOfCards){
        break;
      }
    }
    if (addedCards == numOfCards){
      break;
    }
  }
  [self.gameView setNeedsDisplay];
}

#pragma mark - help methods

- (void) markCardToUpdateRow:(int)CardRow inColumn:(int)CardCol
{
  if (CardCol < 0 || CardRow < 0){
    self.movingCard = nil;
  }
  self.movingCard = _cardAllocation[CardRow][CardCol];
}

- (BOOL)findClosestCard:(CGPoint)center retunrRow:(int &)CardRow returnCol:(int &)CardCol
{
  CGPoint currGirdPlace;
  CardRow = -1;
  CardCol = -1;
  CGFloat minDist = 100;
  for (int i=0; i<_grid.rowCount; i++){
    for (int j=0; j<_grid.columnCount; j++){
      if (!_cardAllocation[i][j]){
        continue;
      }
      currGirdPlace = [self fixOrigin:[self.grid centerOfCellAtRow:i inColumn:j]];
      if (ABS(center.x - currGirdPlace.x) + ABS(center.y - currGirdPlace.y) < minDist){
        minDist = ABS(center.x - currGirdPlace.x) + ABS(center.y - currGirdPlace.y);
        CardRow = i;
        CardCol = j;
      }
    }
  }
  if (CardRow<0 || CardCol<0){
    return NO;
  }
  return YES;
}

- (SetCard *)cardFromView:(SetCardVIew *)view
{
  if (![self.viewAllocation containsObject:view]){
    return nil;
  }
  NSUInteger CardRow = view.rowIndex;
  NSUInteger CardCol = view.colIndex;
  return  _cardAllocation[CardRow][CardCol];
}

#pragma mark - game functions

- (CardMatchingGame *)game{
  if(!_game) {
    
    _game = [[CardMatchingGame alloc] initWithCardCount:[SetCard fullDeckSize] usingDeck:[self createDeck]];
    _game.numOfCardToMatch = NUMBER_OF_CARDS_TO_MATCH;
    _game.choosingPenalty = NO;
    NSArray *deltCards = [self loadCardsToArray:STARTING_CARD_NUMBER];
    [self loadCardsToView:deltCards];
  }
  return _game;
}

- (void)startGame{
  _game = nil;
  _grid = nil;
  [self.viewAllocation makeObjectsPerformSelector:@selector(removeFromSuperview) ];
  _cardAllocation = nil;
  _viewAllocation = nil;
  self.nextCardIndex = 0;
  self.numOfCardsInDisplay = 0;
  [self.collectionCardsView removeFromSuperview];
  [self game];
  [self updateUI];
}

- (NSArray *)loadCardsToArray:(NSUInteger)numOfCards
{
  if (_grid && (numOfCards + self.numOfCardsInDisplay) > _grid.columnCount * _grid.rowCount
      && [self.re_arrangeControl selectedSegmentIndex] == 0){
    [self noMoreCards:@"NO ROOM FOR MORE CARDS"];
    return nil;
  }
  NSMutableArray *cards = [[NSMutableArray alloc]  init];
  for (unsigned int i=0; i < numOfCards; i++){
    if (self.nextCardIndex >= [SetCard fullDeckSize]){
      break;
    }
    SetCard *card = (SetCard *)[self.game cardAtIndex:self.nextCardIndex];
    [cards addObject:card];
    self.nextCardIndex ++;
  }
  return cards;
}

- (void)actionForCard:(SetCard *)card
{
  [self.game chooseCard:card];
  [self updateUI];
}


#pragma mark - user interface

- (void)noMoreCards:(NSString *)msg
{
  UILabel *label = [[UILabel alloc] init];
  label.text = msg;
  [label setFont:[UIFont boldSystemFontOfSize:20.0]];
  label.transform = CGAffineTransformScale(label.transform, 0.25, 0.25);
  label.frame =  CGRectMake(self.gameView.center.x - label.intrinsicContentSize.width/2,
                            self.gameView.center.y - label.intrinsicContentSize.height/2,
                            label.intrinsicContentSize.width,
                            label.intrinsicContentSize.height);
  [label sizeToFit];
  [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    for (UIView *view in _viewAllocation){
      [view setAlpha:0];
    }
  } completion:^(BOOL finished){}];
  [self.gameView addSubview:label];
  [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    label.transform = CGAffineTransformScale(label.transform, 4, 4);
  } completion:^(BOOL finished){}];
  [UIView animateWithDuration:1.0 delay:2.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    label.transform = CGAffineTransformScale(label.transform, 0.01, 0.01);
    [self updateUI];
  } completion:^(BOOL finished){ [label removeFromSuperview];}];
}
@end

NS_ASSUME_NONNULL_END
