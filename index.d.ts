declare module "react-native-scroll-pan-gesture" {
  import type { ViewProps } from "react-native";

  export type ScrollPanGestureNativeEvent = {
    translateY: number;
    velocityY: number;
  };
  export type ScrollPanGestureEvent = {
    nativeEvent: ScrollPanGestureNativeEvent;
  };

  export type Props = ViewProps & {
    enabled?: boolean;
    maxUpwardsDisplacement?: number;
    maxDownwardsDisplacement?: number;
    topOffsetTolerance?: number;
    disableGestureWhenMomentumScrolling?: boolean;
    cancelGestureWhenAfterScrollBarToTop?: boolean;
    onGestureStart?: () => void;
    onGesture?: (event: ScrollPanGestureEvent) => void;
    onGestureEnd?: (event: ScrollPanGestureEvent) => void;
    children: any;
  };

  const ScrollPanGestureView: (props: Props) => JSX.Element;

  export default ScrollPanGestureView;
}
