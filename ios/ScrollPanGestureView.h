#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

@interface ScrollPanGestureView : UIView

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) CGFloat maxUpwardsDisplacement;
@property (nonatomic, assign) CGFloat maxDownwardsDisplacement;
@property (nonatomic, assign) BOOL disableGestureWhenMomentumScrolling;
@property (nonatomic, assign) BOOL cancelGestureAfterDraggingScrollBarToTop;

@property (nonatomic, copy) RCTDirectEventBlock onGesture;
@property (nonatomic, copy) RCTDirectEventBlock onGestureStart;
@property (nonatomic, copy) RCTDirectEventBlock onGestureEnd;

@end
