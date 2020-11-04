/* eslint-disable react-native/no-inline-styles */
import React from 'react';
import {View, Text, TouchableOpacity, Animated, Easing} from 'react-native';
import ScrollPanGestureView from 'react-native-scroll-pan-gesture';

const AnimatedScrollPanGestureView = Animated.createAnimatedComponent(
  ScrollPanGestureView,
);

const collapsedSize = 100;
const expandedSize = 400;
const range = expandedSize - collapsedSize;

export default () => {
  const [gestureValue] = React.useState(() => new Animated.Value(0));
  const [expanded, baseSetExpanded] = React.useState(true);
  const [positionValue] = React.useState(
    () => new Animated.Value(expanded ? 0 : 1),
  );

  const setExpanded = (nextExpanded) => {
    baseSetExpanded(nextExpanded);
    Animated.parallel([
      Animated.timing(positionValue, {
        toValue: nextExpanded ? 0 : 1,
        easing: Easing.out(Easing.exp),
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(gestureValue, {
        toValue: 0,
        easing: Easing.out(Easing.exp),
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const translateY = Animated.add(
    Animated.multiply(positionValue, range),
    gestureValue,
  );

  return (
    <View style={{flex: 1, backgroundColor: '#eee'}}>
      <AnimatedScrollPanGestureView
        style={{
          position: 'absolute',
          width: '100%',
          height: expandedSize,
          bottom: 0,
          backgroundColor: 'white',
          transform: [{translateY}],
        }}
        onGesture={Animated.event([{nativeEvent: {translateY: gestureValue}}], {
          useNativeDriver: true,
        })}
        onGestureEnd={(e) => {
          const {translateY: tY, velocityY: vY} = e.nativeEvent;
          let nextExpanded;
          if (expanded) {
            nextExpanded = Math.abs(vY) > 100 ? vY < 0 : tY < range / 2;
          } else {
            nextExpanded = vY < 0;
          }
          setExpanded(nextExpanded);
        }}
        maxUpwardsDisplacement={!expanded ? range : 0}
        maxDownwardsDisplacement={expanded ? range : 0}
        enabled={true}>
        <Animated.ScrollView contentContainerStyle={{height: 1000}}>
          <Text style={{textAlign: 'center', margin: 20}}>Drag Me</Text>
          <TouchableOpacity onPress={() => setExpanded(!expanded)}>
            <Text style={{textAlign: 'center', margin: 20}}>
              Toggle Expanded
            </Text>
          </TouchableOpacity>
        </Animated.ScrollView>
      </AnimatedScrollPanGestureView>
    </View>
  );
};
