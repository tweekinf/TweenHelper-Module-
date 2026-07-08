# TweenHelper

A lightweight, type-safe tweening module for Roblox Studio.

TweenHelper is a clean wrapper around Roblox's built-in TweenService that makes animations easier to create, manage, and chain together.

It provides a simple API for common animations such as fading, sliding, popping, pulsing, and shaking while supporting custom tweens, sequences, and parallel animations.

---

# Features

- Fully typed API using `--!strict`
- Full autocomplete support
- Works with any tweenable Roblox property
- Built-in animation presets
- Tween chaining
- Sequential animation support
- Parallel tween groups
- Automatic tween handling
- Supports GUI objects and 3D objects
- Uses Roblox TweenService internally

---

# Installation

Place the module somewhere accessible, for example:

```
ReplicatedStorage
└── Modules
    └── TweenHelper
```

Require the module:

```lua
local TweenHelper = require(game.ReplicatedStorage.Modules.TweenHelper)
```

---

# Basic Usage

Create a simple tween:

```lua
TweenHelper.Create(Frame, {
    Position = UDim2.fromScale(0.5, 0.5)
}):Play()
```

TweenHelper automatically creates the TweenInfo and handles the tween setup.

---

# Custom Tweens

You can customize your animations using an easing configuration.

Example:

```lua
TweenHelper.Create(Frame, {
    Size = UDim2.fromScale(0.5, 0.5)
}, {
    Time = 0.5,
    Style = Enum.EasingStyle.Back,
    Direction = Enum.EasingDirection.Out
}):Play()
```

Available options:

| Option | Description |
|---|---|
| Time | Duration of the tween |
| Style | Easing style |
| Direction | Easing direction |
| RepeatCount | Number of repeats |
| Reverses | Reverse the tween after playing |
| DelayTime | Delay before starting |

---

# Built-in Animations

TweenHelper includes several ready-to-use animations.

## Fade

Fade a GUI object in:

```lua
TweenHelper.FadeIn(Frame)
```

Fade a GUI object out:

```lua
TweenHelper.FadeOut(Frame)
```

Supported objects:

- Frame
- ScrollingFrame
- TextLabel
- TextButton
- ImageLabel
- ImageButton

TweenHelper automatically detects which transparency properties need changing.

---

# Slide

Slide an object into its original position:

```lua
TweenHelper.SlideIn(Frame, "Left")
```

Available directions:

```lua
"Left"
"Right"
"Up"
"Down"
```

Example:

```lua
TweenHelper.SlideIn(Frame, "Right", 0.5, 500)
```

Parameters:

```lua
(guiObject, direction, time, distance)
```

Slide an object away:

```lua
TweenHelper.SlideOut(Frame, "Left")
```

---

# Pop

Create a pop-in animation:

```lua
TweenHelper.Pop(Frame)
```

Create a pop-out animation:

```lua
TweenHelper.PopOut(Frame)
```

Useful for:

- Menus
- Buttons
- Notifications
- Dialogs

---

# Pulse

Create a looping scale animation:

```lua
TweenHelper.Pulse(Button)
```

Custom scale and timing:

```lua
TweenHelper.Pulse(Button, 1.2, 0.5)
```

Parameters:

```lua
(guiObject, scaleMultiplier, time)
```

---

# Shake

Shake GUI objects or 3D parts.

GUI example:

```lua
TweenHelper.Shake(Frame)
```

Part example:

```lua
TweenHelper.Shake(workspace.Part)
```

Custom strength and duration:

```lua
TweenHelper.Shake(Frame, 10, 0.5)
```

The function returns a stop function:

```lua
local stopShake = TweenHelper.Shake(Frame)

task.wait(1)

stopShake()
```

---

# Tween Handles

Every tween created using `TweenHelper.Create()` returns a TweenHandle.

TweenHandle methods:

```lua
:Play()
:Pause()
:Cancel()
:Wait()
:OnComplete(callback)
:Then(function)
```

Example:

```lua
TweenHelper.Create(Frame, {
    Size = UDim2.fromScale(1,1)
})
:Play()
:OnComplete(function()
    print("Tween finished")
end)
```

---

# Tween Chaining

Animations can be chained together.

Example:

```lua
TweenHelper.Pop(Frame)
    :Then(function()
        return TweenHelper.FadeOut(Frame)
    end)
```

The next animation will only start after the previous tween completes.

---

# Sequences

Sequences allow animations to run one after another.

Example:

```lua
TweenHelper.Sequence({

    function()
        return TweenHelper.FadeIn(Frame)
    end,

    function()
        return TweenHelper.Pop(Frame)
    end,

    function()
        return TweenHelper.SlideOut(Frame, "Left")
    end

})
```

Each animation waits until the previous one finishes.

---

# Parallel Animations

Parallel animations allow multiple tweens to run at the same time.

Example:

```lua
TweenHelper.Parallel({

    function()
        return TweenHelper.FadeIn(Frame)
    end,

    function()
        return TweenHelper.Pop(Frame)
    end,

    function()
        return TweenHelper.SlideIn(Frame, "Up")
    end

})
```

All animations start together.

---

# How It Works

TweenHelper does not replace Roblox TweenService.

It improves the developer experience by removing repetitive code.

Normally, creating animations requires:

- Creating TweenInfo objects repeatedly
- Setting easing styles manually
- Connecting completion events
- Handling common animation patterns yourself

TweenHelper provides reusable functions for these tasks while keeping the power and performance of TweenService.

---

# Example Project Usage

```lua
local TweenHelper = require(game.ReplicatedStorage.Modules.TweenHelper)

TweenHelper.Sequence({

    function()
        return TweenHelper.FadeIn(Menu)
    end,

    function()
        return TweenHelper.Pop(Menu)
    end,

    function()
        return TweenHelper.Pulse(StartButton)
    end

})
```

---

# API Overview

## TweenHelper.Create()

Creates a custom tween.

```lua
TweenHelper.Create(instance, properties, config)
```

---

## TweenHelper.FadeIn()

Fades a GUI object in.

```lua
TweenHelper.FadeIn(guiObject, time)
```

---

## TweenHelper.FadeOut()

Fades a GUI object out.

```lua
TweenHelper.FadeOut(guiObject, time)
```

---

## TweenHelper.SlideIn()

Slides an object into position.

```lua
TweenHelper.SlideIn(guiObject, direction, time, distance)
```

---

## TweenHelper.SlideOut()

Slides an object away.

```lua
TweenHelper.SlideOut(guiObject, direction, time, distance)
```

---

## TweenHelper.Pop()

Creates a pop-in animation.

```lua
TweenHelper.Pop(guiObject, time)
```

---

## TweenHelper.PopOut()

Creates a pop-out animation.

```lua
TweenHelper.PopOut(guiObject, time)
```

---

## TweenHelper.Pulse()

Creates a repeating pulse animation.

```lua
TweenHelper.Pulse(guiObject, multiplier, time)
```

---

## TweenHelper.Shake()

Creates a shake effect.

```lua
TweenHelper.Shake(instance, strength, duration)
```

---

## TweenHelper.Sequence()

Runs animations in order.

```lua
TweenHelper.Sequence(actions)
```

---

## TweenHelper.Parallel()

Runs animations together.

```lua
TweenHelper.Parallel(actions)
```

---

# License

Free to use in personal and commercial Roblox projects.

Credit is appreciated but not required.
