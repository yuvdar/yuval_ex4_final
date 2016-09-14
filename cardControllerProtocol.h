// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

NS_ASSUME_NONNULL_BEGIN
@protocol cardControllerProtocol <NSObject>

@property (strong, nonatomic)  id deck;
@property (strong, nonatomic) CardMatchingGame *game;
@property (nonatomic) int lastScore;
@property (strong, nonatomic) NSMutableArray *chosenCards;


- (void)actionForSwipe:(UISwipeGestureRecognizer *)sender fromDirection:(UIViewAnimationOptions)direction;
- (void)actionForCard:(id) cardIndex;
- (void)startGame;
- (void)updateUI;

@optional
- (void)resetChosenCards:(BOOL)resetChosen;
@end

NS_ASSUME_NONNULL_END
