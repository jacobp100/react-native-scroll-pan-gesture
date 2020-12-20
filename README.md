# react-native-scroll-pan-gesture

Scroll pan gesture view for React Native for building [bottom sheets](https://stackoverflow.com/questions/37967555/how-can-i-mimic-the-bottom-sheet-from-the-maps-app).

Replaces scroll events with a pan gesture-like event (and disables scrolling while the pan gesture is in progress). Implemented in native code, so it's (hopefully) less buggy than JS versions.

**This is not a bottom sheet component**, it is a low-level component indended for library authors.

Only works on iOS. Exports `null` on other platforms - **make sure you handle this case!**

```
yarn add react-native-scroll-pan-gesture
```

## Usage

```javascript
import { ScrollView } from "react-native"; // Regular scroll view
import ScrollPanGestureView from "react-native-scroll-pan-gesture";

const Example = (
  <ScrollPanGesture
    // This creates an extra UIView, so be careful of layout changes.
    style={{ flex: 1 }}
    // Override scroll events with a pan gesture for this amount downwards,
    // then go back to regular scrolling.
    //
    // Set to 0 (or less) to disable the pan gesture in this direction.
    maxDownwardsDisplacement={300}
    // Same as above, but upwards.
    maxUpwardsDisplacement={0}
    // Called when gesture starts.
    onGestureStart={() => {}}
    // Called for each gesture event.
    onGesture={(e) => {
      const { translateY, velocityY } = e.nativeEvent;
      // Do something with translateY and/or velocityY.
      // This can (and probably should) be an `Animated.event`.
    }}
    // Called when gesture ends/is cancelled.
    onGestureEnd={(e) => {
      const { translateY, velocityY } = e.nativeEvent;
      // Do something with translateY and/or velocityY.
    }}
    // If your scrollviews have their translateX/translateY animated while the
    // user has their finger down on the scrollview, the content offset can
    // change (very) slightly during the animation. So you could have been at
    // the top of the scroll, but the pan gesture didn't fire, because the
    // content offset was off by a few points. Keep increasing this value until
    // the gesture works flawlessly - but no further.
    topOffsetTolerance={2}
    // If scrolling started when momentum scrolling was already in progress,
    // disable the pan gesture.
    //
    // Defaults to true. You probably don't want to change this.
    disableGestureWhenMomentumScrolling={true}
    // Stops the gesture if you drag the scroll bar to the top,
    // otherwise it will begin a downwards pan gesture.
    //
    // This is what happens in Apple Maps.
    //
    // Defaults to true.
    //
    // There's no official way to detect this, so a heuristic is used.
    // The heuristic can be a bit too aggressive, so you might want to disable
    // it if scroll indicators are disabled.
    cancelGestureAfterDraggingScrollBarToTop={true}
  >
    <ScrollView>{content}</ScrollView>
  </ScrollPanGesture>
);
```

## Issues with JS-Based Gestures

It's not really possible to access the scrollview's pan gesture from the JS side. Every bottom sheet I've seen (including my own) made the assumption that you could create a new pan gesture, and that a 1px move on the pan gesture would be a 1px move on the scrollview in the same direction.

iOS 13 introduced the ability to touch and hold on a scrollview's scrollbar, and drag them. This not only meant the 1px to 1px ratio will now be off, it'll also be in the opposite direction. This means JS implementations dismiss the bottom sheet while scrolling upwards with the scrollbar.
