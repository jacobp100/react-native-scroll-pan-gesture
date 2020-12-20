#import "ScrollPanGestureViewManager.h"

#import "ScrollPanGestureView.h"

@implementation ScrollPanGestureViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[ScrollPanGestureView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(enabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(maxUpwardsDisplacement, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(maxDownwardsDisplacement, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(topOffsetTolerance, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(disableGestureWhenMomentumScrolling, BOOL)
RCT_EXPORT_VIEW_PROPERTY(cancelGestureAfterDraggingScrollBarToTop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onGesture, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onGestureStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onGestureEnd, RCTDirectEventBlock)

@end
