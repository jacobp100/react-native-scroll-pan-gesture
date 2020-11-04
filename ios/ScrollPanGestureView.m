#import "ScrollPanGestureView.h"
#import <React/UIView+React.h>
#import <React/RCTLog.h>

@implementation ScrollPanGestureView {
  UIScrollView *_scrollview;
  BOOL _wasMomentumScrolling;
  BOOL _lastGestureEventWasPanGesture;
  CGFloat _upwardsGestureOriginY;
  CGFloat _translateY;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _scrollview = nil;
    _wasMomentumScrolling = NO;
    _lastGestureEventWasPanGesture = NO;
    _upwardsGestureOriginY = 0;
    _translateY = 0;
    _enabled = YES;
    _maxUpwardsDisplacement = 0;
    _maxDownwardsDisplacement = 0;
    _disableGestureWhenMomentumScrolling = YES;
    _cancelGestureAfterDraggingScrollBarToTop = YES;
  }
  return self;
}

- (nullable UIScrollView *)resolveScrollView:(UIView *)subview
{
  if ([subview isKindOfClass:UIScrollView.class]) {
    return (id)subview;
  } else if (
    subview.subviews.count != 0 &&
    [subview.subviews[0] isKindOfClass:UIScrollView.class]
  ) {
    return (id)subview.subviews[0];
  } else {
    return nil;
  }
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  [super insertReactSubview:subview atIndex:atIndex];
  UIScrollView* scrollview = [self resolveScrollView:subview];

  if (scrollview != nil && _scrollview != nil) {
    RCTLogError(@"Expected no more than one scroll view");
  } else if (scrollview != nil) {
    _scrollview = scrollview;
    [scrollview.panGestureRecognizer addTarget:self
                                        action:@selector(handlePanGesture:)];
  }
}

- (void)removeReactSubview:(UIView *)subview
{
  [super removeReactSubview:subview];
  UIScrollView* scrollview = [self resolveScrollView:subview];

  if (scrollview != nil && scrollview == _scrollview) {
    _scrollview = nil;
    [scrollview.panGestureRecognizer removeTarget:self
                                           action:@selector(handlePanGesture:)];
  }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
  if (!_enabled) {
    return;
  } else if (recognizer.view != _scrollview) {
    RCTLogError(@"Invalid gesture state");
    return;
  }

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    _wasMomentumScrolling =
      _disableGestureWhenMomentumScrolling &&
      _scrollview.isDecelerating;
  } else if (_wasMomentumScrolling) {
    return;
  }

  CGFloat offsetY = _scrollview.contentOffset.y;
  BOOL downwardsGestureEnabled = _maxDownwardsDisplacement > 0;
  BOOL upwardsGestureEnabled = _maxUpwardsDisplacement > 0;

  if (
    _cancelGestureAfterDraggingScrollBarToTop &&
    recognizer.state == UIGestureRecognizerStateChanged &&
    downwardsGestureEnabled &&
    offsetY < 0 &&
    [recognizer velocityInView:_scrollview].y < 0
  ) {
    recognizer.enabled = NO;
    recognizer.enabled = YES;
    _scrollview.contentOffset = CGPointMake(_scrollview.contentOffset.x, 0);
    _onGestureEnd([self eventData:recognizer cancelled:YES]);
    return;
  }

  switch (recognizer.state) {
    case UIGestureRecognizerStatePossible:
      break;
    case UIGestureRecognizerStateBegan: {
      _lastGestureEventWasPanGesture = NO;
      _upwardsGestureOriginY = MAX(_scrollview.contentOffset.y, 0);
      _translateY = 0;

      if (_onGestureStart != nil) {
        _onGestureStart(@{});
      }

      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_onGestureEnd != nil) {
        _onGestureEnd([self eventData:recognizer cancelled:NO]);
      }
      break;
    }
    case UIGestureRecognizerStateCancelled: {
      if (_onGestureEnd != nil) {
        _onGestureEnd([self eventData:recognizer cancelled:YES]);
      }
      break;
    }
    case UIGestureRecognizerStateChanged: {
      BOOL triggerGestureDownwards =
        downwardsGestureEnabled && (
          (offsetY < 0 && _translateY < _maxDownwardsDisplacement) ||
          (offsetY > 0 && _translateY > 0)
        );
      BOOL triggerGestureUpwards =
        upwardsGestureEnabled && (
          (offsetY > _upwardsGestureOriginY && _translateY > -_maxUpwardsDisplacement) ||
          (offsetY < _upwardsGestureOriginY && _translateY < 0)
        );

      if (triggerGestureDownwards) {
        _lastGestureEventWasPanGesture = YES;
        _translateY = MIN(MAX(_translateY - offsetY, 0), _maxDownwardsDisplacement);
        _upwardsGestureOriginY = 0;
        _scrollview.contentOffset = CGPointMake(_scrollview.contentOffset.x, 0);
      } else if (triggerGestureUpwards) {
        _lastGestureEventWasPanGesture = YES;
        CGFloat dy = offsetY - _upwardsGestureOriginY;
        _translateY = MAX(MIN(_translateY - dy, 0), -_maxUpwardsDisplacement);
        _scrollview.contentOffset = CGPointMake(_scrollview.contentOffset.x, _upwardsGestureOriginY);
      } else {
        _lastGestureEventWasPanGesture = NO;
        _upwardsGestureOriginY = MAX(MIN(_upwardsGestureOriginY, offsetY), 0);
      }

      if ((triggerGestureDownwards || triggerGestureUpwards) && _onGesture != nil) {
        _onGesture([self eventData:recognizer cancelled:NO]);
      }

      break;
    }
    case UIGestureRecognizerStateFailed:
      break;
    default:
      break;
  }
}

- (id)eventData:(UIPanGestureRecognizer *)recognizer cancelled:(BOOL)cancelled
{
  CGFloat translateY = !cancelled ? _translateY : 0;
  CGFloat velocityY = !cancelled && _lastGestureEventWasPanGesture
    ? [recognizer velocityInView:_scrollview].y
    : 0;
  return @{
    @"translateY": @(translateY),
    @"velocityY": @(velocityY),
  };
}

@end
