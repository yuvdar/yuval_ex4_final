// Copyright (c) 2016 Lightricks. All rights reserved.
// Created by Yuval Dar.

#import "SetCardVIew.h"
@interface SetCardVIew()
@property (nonatomic) CGFloat faceCardScaleFactor;

@end

@implementation SetCardVIew

#pragma mark - MACROS
#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90


#pragma mark - setters ang getters
@synthesize faceCardScaleFactor = _faceCardScaleFactor;

- (CGFloat)faceCardScaleFactor
{
  if (!_faceCardScaleFactor) _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;
    return _faceCardScaleFactor;
}



- (void)setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
{
  _faceCardScaleFactor = faceCardScaleFactor;
  [self setNeedsDisplay];
}

- (void)setSuit:(NSString *)suit
{
  _suit = suit;
  [self setNeedsDisplay];
}

- (void)setColor:(NSString *)color
{
  _color = color;
  [self setNeedsDisplay];
}

- (void)setShading:(NSString *)shading
{
  _shading = shading;
  [self setNeedsDisplay];
}

- (void)setRank:(NSUInteger)rank
{
  _rank = rank;
  [self setNeedsDisplay];
}


#pragma mark - constArrays and dictionaries

-(UIColor *)colorForName:(NSString *)colorName
{
  NSDictionary *dict = @{@"purple" : [UIColor purpleColor],
                         @"red" : [UIColor redColor],
                         @"green" : [UIColor greenColor]};
  return dict[colorName];
}


#pragma mark - Drawing

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  // Drawing code
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
  
  [roundedRect addClip];
  
  [[UIColor whiteColor] setFill];
  UIRectFill(self.bounds);
  
  [[UIColor blackColor] setStroke];
  [roundedRect stroke];
   UIBezierPath *finalShape = [[UIBezierPath alloc] init];
  for (int i=0; i<self.rank; i++){
    UIBezierPath *shape;
    CGPoint drawPoint = CGPointMake(self.bounds.size.width * (i+1)/(self.rank+1), self.bounds.size.height/2) ;
    if ([self.suit isEqualToString:@"diamond"]){
      shape = [self drawDiamondAtPoint:drawPoint];
    } else if ([self.suit isEqualToString:@"oval"]){
      shape = [self drawOvalAtPoint:drawPoint];
    } else if ([self.suit isEqualToString:@"squiggle"]){
      shape = [self drawSquigglesAtPoint:drawPoint];
    }
    [finalShape appendPath:shape];
  }
  finalShape.lineWidth = 2.0;
  [finalShape addClip];
  
  [self addShading:finalShape];
  [finalShape stroke];
}

- (UIBezierPath *)drawOvalAtPoint:(CGPoint) point
{
  CGRect ovalRect = CGRectInset(self.bounds,
                                 self.bounds.size.width * (1.0-self.faceCardScaleFactor) * 4.0,
                                 self.bounds.size.height * (1.0-self.faceCardScaleFactor));
  ovalRect.origin.x = point.x - ovalRect.size.width/2;
  UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
  return oval;
}



- (UIBezierPath *)drawSquigglesAtPoint:(CGPoint) point
{
  UIBezierPath *squiggle = [[UIBezierPath alloc] init];
  
  CGFloat dx = self.bounds.size.width * 0.1;
  CGFloat dy = self.bounds.size.height * 0.2;
  CGFloat dsqx = dx * 0.8;
  CGFloat dsqy = dy * 0.8;
  
  [squiggle moveToPoint:CGPointMake(point.x - dx, point.y - dy)];
  [squiggle addQuadCurveToPoint:CGPointMake(point.x + dx, point.y - dy)
               controlPoint:CGPointMake(point.x - dsqx, point.y - dy - dsqy)];
  [squiggle addCurveToPoint:CGPointMake(point.x + dx, point.y + dy)
          controlPoint1:CGPointMake(point.x + dx + dsqx, point.y - dy + dsqy)
          controlPoint2:CGPointMake(point.x + dx - dsqx, point.y + dy - dsqy)];
  [squiggle addQuadCurveToPoint:CGPointMake(point.x - dx, point.y + dy)
               controlPoint:CGPointMake(point.x + dsqx, point.y + dy + dsqy)];
  [squiggle addCurveToPoint:CGPointMake(point.x - dx, point.y - dy)
          controlPoint1:CGPointMake(point.x - dx - dsqx, point.y + dy - dsqy)
          controlPoint2:CGPointMake(point.x - dx + dsqx, point.y - dy + dsqy)];

  [squiggle closePath];
  return squiggle;

}

- (UIBezierPath *)drawDiamondAtPoint:(CGPoint) point
{
  UIBezierPath *diamond = [[UIBezierPath alloc] init];
  CGPoint bottom = CGPointMake(point.x, self.bounds.size.height*8.0/9.0);
  CGPoint left = CGPointMake(point.x + self.bounds.size.width/10.0, self.bounds.size.height/2.0);
  CGPoint top = CGPointMake(point.x, self.bounds.size.height/9.0);
  CGPoint right = CGPointMake(point.x - self.bounds.size.width/10.0, self.bounds.size.height/2.0);
  [diamond moveToPoint:bottom];
  [diamond addLineToPoint:left];
  [diamond addLineToPoint:top];
  [diamond addLineToPoint:right];
  [diamond closePath];
  return diamond;
 

}


- (void)addShading:(UIBezierPath *)shape
{
  
  UIColor *shapeColor = [self colorForName:self.color];
  [shapeColor setStroke];
  if ([self.shading isEqualToString:@"solid"]){
    [shapeColor setFill];
    [shape fill];
  } else if ([self.shading isEqualToString:@"striped"]){
    [self addStokesToShapeWithColor:shapeColor];
  }

 
  


}

- (void)addStokesToShapeWithColor:(UIColor *)color
{
  
  static const int numberOfStripes = 15;
  static const int delta = 3;
  CGFloat step = (self.bounds.size.height)/(numberOfStripes + delta);
  for (int i=0; i<numberOfStripes; i++){
    UIBezierPath *stripe = [[UIBezierPath alloc] init];
    CGPoint p0 = CGPointMake(self.bounds.size.width, i*step);
    CGPoint p1 = CGPointMake(self.bounds.origin.x, (delta + i)*step);
    [stripe moveToPoint:p0];
    [stripe addLineToPoint:p1];
    [color setStroke];
    stripe.lineWidth = 1.0;
    [stripe stroke];
  }
  
}

#pragma mark - Initialization

- (void)setup
{
  self.backgroundColor = nil;
  self.opaque = NO;
  self.contentMode = UIViewContentModeRedraw;
  
}

- (void)awakeFromNib
{
  [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  [self setup];
  return self;
}

@end