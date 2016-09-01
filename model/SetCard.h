// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

# import "Card.h"
NS_ASSUME_NONNULL_BEGIN

@interface SetCard : Card
@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic)  NSString *shading;


+ (NSArray *)validSuits;
+ (NSUInteger) maxRank;
+ (NSArray *)validColors;
+ (NSArray *)validfill;


@end

NS_ASSUME_NONNULL_END
