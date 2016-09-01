// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "Card.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger) maxRank;
@end

NS_ASSUME_NONNULL_END
