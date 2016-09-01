// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "cardHistoryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface cardHistoryViewController()
@property (weak, nonatomic) IBOutlet UITextView *historyUItext;


@end


@implementation cardHistoryViewController

-(void)updateHistoryText:(NSAttributedString *)text
{
  _textToDisplay = text;
  if (self.view.window) [self updateUI];
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self updateUI];
}

-(void)updateUI
{
  self.historyUItext.attributedText = self.textToDisplay;
}

@end

NS_ASSUME_NONNULL_END
