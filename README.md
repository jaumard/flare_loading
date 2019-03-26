# flare_loading

[![pub package](https://img.shields.io/pub/v/flare_loading.svg)](https://pub.dartlang.org/packages/flare_loading)

Loading widget based on a Flare animation, allow you to create custom loading widgets or dialogs

## Usage

```dart
FlareLoading(
  name: 'animation.flr', 
  startAnimation: 'intro',
  loopAnimation: 'circle',
  endAnimation: 'end',
);
```

`name`: path and name of the flare animation

`until`: callback that return a future to process your initialization

`isLoading`: alternative to `until` if you want to manage loading state with a boolean

`endAnimation`: animation name to run once `until` is complete or `isLoading` false

`startAnimation`: animation name to run once as start

`height`: force the height of the flare animation, by default it take the all place available

`width`: force the width of the flare animation, by default it take the all place available

`alignment`: alignment of the flare animation, center by default

`onFinished` callback called when the animation is finished and `isLoading` is false or `until` is complete

## Available mode

### Only one animation 
Basically you have one animation to show and then just need to stay at last frame. In order to do that only specify the `startAnimation` 

### Start and loop animation 
Your animation have an intro and a loop state, in order to do that only specify the `startAnimation` and `loopAnimation`

### End and loop animation 
Your animation have a finish and a loop state, in order to do that only specify the `endAnimation` and `loopAnimation`

### Start and end animation 
Your animation have an intro and a finish that should stay on the last frame, in order to do that only `startAnimation` and `endAnimation`

### Start, end and loop animation 
Your animation have an intro, a finish and a loop state, in order to do that specify the `startAnimation`, `endAnimation` and `loopAnimation`
