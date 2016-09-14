// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SetCardVIew : UIView

@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;
@property (strong, nonatomic) NSString *shading;
@property (strong, nonatomic) NSString *color;
@property (nonatomic) NSUInteger rowIndex;
@property (nonatomic) NSUInteger colIndex;
@end

NS_ASSUME_NONNULL_END
