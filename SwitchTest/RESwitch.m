//
//  RESwitch.m
//  SwitchTest
//
//  Created by Roman Efimov on 2/4/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "RESwitch.h"

//#define kKnobOffset 4

@implementation RESwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _knobXOffset = 0;
        _knobYOffset = 0;
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 2, frame.size.height)];
        _backgroundView.userInteractionEnabled = YES;
        [_containerView addSubview:_backgroundView];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
        [_backgroundView addSubview:_backgroundImageView];
        
        _overlayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_overlayImageView];
        
        _knobView = [[UIImageView alloc] initWithFrame:CGRectNull];
        [self addSubview:_knobView];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerDidChange:)];
        [_backgroundView addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidChange:)];
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)radius
{
    _containerView.layer.cornerRadius = radius;
    _containerView.layer.masksToBounds = YES;
}

- (CGFloat)cornerRadius
{
    return _containerView.layer.cornerRadius;
}

- (void)setKnobOffsetX:(CGFloat)x y:(CGFloat)y
{
    _knobXOffset = x;
    _knobYOffset = y;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _backgroundImageView.image = _backgroundImage;
    _overlayImageView.image = _overlayImage;
    _knobView.image = _knobImage;
    
    
    _backgroundImageView.frame = CGRectMake(0, 0, _backgroundImage.size.width, _backgroundImage.size.height);
    CGRect frame = _backgroundView.frame;
    CGRect knobFrame = CGRectMake(0, 0, _knobImage.size.width, _knobImage.size.height);
    knobFrame.origin.x = frame.origin.x + self.frame.size.width - knobFrame.size.width + _knobXOffset;
    knobFrame.origin.y = _knobYOffset;
    _knobView.frame = knobFrame;
}

#pragma mark -
#pragma mark Apperance

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    NSLog(@"set background");
    _backgroundImage = backgroundImage;
    [self setNeedsLayout];
}

- (void)setOverlayImage:(UIImage *)overlayImage
{
    _overlayImage = overlayImage;
    [self setNeedsLayout];
}

- (void)setKnobImage:(UIImage *)knobImage
{
    _knobImage = knobImage;
    [self setNeedsLayout];
}

- (void)setHighlightedKnobImage:(UIImage *)highlightedKnobImage
{
    _highlightedKnobImage = highlightedKnobImage;
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Gesture recognizers

- (void)panGestureRecognizerDidChange:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:_backgroundView];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		_initialOffset = _backgroundView.frame.origin.x;
	}
	
	float x = translation.x;
	x = translation.x + _initialOffset;
    
    CGRect frame = _backgroundView.frame;
    frame.origin.x = x;
    if (frame.origin.x > 0) {
        frame.origin.x = 0;
    }
    if (frame.origin.x < -self.frame.size.width + _knobView.frame.size.width - _knobXOffset*2)
        frame.origin.x = -self.frame.size.width + _knobView.frame.size.width - _knobXOffset*2;
    _backgroundView.frame = frame;
    
    CGRect knobFrame = _knobView.frame;
    knobFrame.origin.x = frame.origin.x + self.frame.size.width - knobFrame.size.width + _knobXOffset;
    _knobView.frame = knobFrame;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_highlightedKnobImage)
            _knobView.image = _highlightedKnobImage;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _knobView.image = _knobImage;
        
        if (frame.origin.x > -self.frame.size.width / 2) {
            frame.origin.x = 0;
        } else {
            frame.origin.x = -self.frame.size.width + _knobView.frame.size.width - _knobXOffset*2;
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            _backgroundView.frame = frame;
            
            CGRect knobFrame = _knobView.frame;
            knobFrame.origin.x = frame.origin.x + self.frame.size.width - knobFrame.size.width + _knobXOffset;
            _knobView.frame = knobFrame;
        }];
    }
}

- (void)tapGestureRecognizerDidChange:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _knobView.image = _knobImage;

        CGRect frame = _backgroundView.frame;

        if (frame.origin.x == 0) {
            frame.origin.x = -self.frame.size.width + _knobView.frame.size.width - _knobXOffset*2;
        } else {
            frame.origin.x = 0;
        }
        [UIView animateWithDuration:0.15 animations:^{
            _backgroundView.frame = frame;

            CGRect knobFrame = _knobView.frame;
            knobFrame.origin.x = frame.origin.x + self.frame.size.width - knobFrame.size.width + _knobXOffset;
            _knobView.frame = knobFrame;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_highlightedKnobImage)
        _knobView.image = _highlightedKnobImage;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _knobView.image = _knobImage;
}

@end
