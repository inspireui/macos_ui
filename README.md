# macos_ui

Flutter widgets and themes implementing the current macOS design language.

[![Flutter Analysis](https://github.com/GroovinChip/macos_ui/actions/workflows/flutter_analysis.yml/badge.svg)](https://github.com/GroovinChip/macos_ui/actions/workflows/flutter_analysis.yml)
[![Pana Analysis](https://github.com/GroovinChip/macos_ui/actions/workflows/pana_analysis.yml/badge.svg)](https://github.com/GroovinChip/macos_ui/actions/workflows/pana_analysis.yml)
[![codecov](https://github.com/GroovinChip/macos_ui/actions/workflows/codecov.yaml/badge.svg)](https://github.com/GroovinChip/macos_ui/actions/workflows/codecov.yaml)
[![codecov](https://codecov.io/gh/GroovinChip/macos_ui/branch/dev/graph/badge.svg?token=1SZGEVVMCH)](https://codecov.io/gh/GroovinChip/macos_ui)

NOTE: This package depends on the excellent [native_context_menu](https://pub.dev/packages/native_context_menu) plugin.
Since it is a desktop plugin, and therefore does not target Android and iOS, the pub score of this package
is lower than 130

## Content

- [macos_ui](#macos_ui)
  - [Content](#content)
  - [Contributing](#contributing)
  - [Resources](#resources)
- [Layout](#layout)
  - [MacosWindow](#macoswindow)
  - [MacosScaffold](#macosscaffold)
  - [MacosListTile](#MacosListTile)
- [Icons](#icons)
  - [MacosIcon](#MacosIcon)
- [Buttons](#buttons)
  - [MacosCheckbox](#macoscheckbox)
  - [HelpButton](#helpbutton)
  - [RadioButton](#radiobutton)
  - [PushButton](#pushbutton)
  - [MacosSwitch](#macosswitch)
- [Dialogs and Sheets](#dialogs)
  - [MacosAlertDialog](#MacosAlertDialog)
  - [MacosSheet](#MacosSheet)
- [Context Menus](#ContextMenus)
- [Fields](#fields)
  - [MacosTextField](#macostextfield)
- [Labels](#labels)
  - [MacosTooltip](#macostooltip)
- [Indicators](#indicators)
  - [Progress Indicators](#progress-indicators)
    - [ProgressCircle](#progresscircle)
    - [ProgressBar](#progressbar)
  - [Level Indicators](#level-indicators)
    - [CapacityIndicator](#capacityindicator)
    - [RatingIndicator](#ratingindicator)
    - [RelevanceIndicator](#relevanceindicator)

## Contributing

macOS welcomes contributions. Please see CONTRIBUTING.md for more information.

## Resources

- [macOS Design Resources](https://developer.apple.com/design/resources/)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [macOS Big Sur Figma kit](https://www.figma.com/file/M6K5L3GK0WJh6pnsASyVeE/macOS-Big-Sur-UI-Kit?node-id=1%3A2)

# Layout

## MacosWindow

`MacosWindow` is the basic frame for the macOS layout.

It has a `Sidebar` on the left and the rest of the window is typically filled out
with a `MacosScaffold`. A scope for the `MacosWindow` is provided by `MacosWindowScope`.
The sidebar can be toggled with `MacosWindowScope.of(context).toggleSidebar()`. Please note that you must
wrap your `MacosScaffold` in a `Builder` widget in order for this to work properly.

<img src="https://imgur.com/LtdfKvv.png" width="75%">


## MacosScaffold

The `MacosScaffold` is what you would call a "page".

The scaffold has a `TitleBar` property and the `children` property which accepts a `ContentArea` widget and multiple `ResizablePane` widgets. To catch navigation or routes below the scaffold, consider wrapping the `MacosScaffold` in a [`CupertinoTabView`](https://api.flutter.dev/flutter/cupertino/CupertinoTabView-class.html). By doing so, navigation inside the `MacosScaffold` will be displayed inside the `MacosScaffold` area instead of covering the entire window. To push a route outside a `MacosScaffold` wrapped in a [`CupertinoTabView`](https://api.flutter.dev/flutter/cupertino/CupertinoTabView-class.html), use the root navigator `Navigator.of(context, rootNavigator: true)`

See the documentation for customizations.

<img src="https://imgur.com/waUgeWY.png" width="75%"/>

<img src="https://imgur.com/DihgZmC.png" width="75%"/>

<img src="https://imgur.com/mabmh61.png" width="75%"/>

## Modern window look

A new look for macOS apps was introduced in Big Sur (macOS 11). To match that look in your Flutter app, like our screenshots, your `macos/Runner/MainFlutterWindow.swift` file should look like this.

```swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    if #available(macOS 10.13, *) {
      let customToolbar = NSToolbar()
      customToolbar.showsBaselineSeparator = false
      self.toolbar = customToolbar
    }
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    if #available(macOS 11.0, *) {
      self.toolbarStyle = .unified
    }

    self.isMovableByWindowBackground = true
    self.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

```

## MacosListTile

A widget that aims to approximate the [ListTile] widget found in
Flutter's material library.

![MacosListTile](https://imgur.com/pQB99M2.png)

Usage:
```dart
MacosListTile(
  leading: const Icon(CupertinoIcons.lightbulb),
  title: Text(
    'A robust library of Flutter components for macOS',
    style: MacosTheme.of(context).typography.headline,
  ),
  subtitle: Text(
    'Create native looking macOS applications using Flutter',
    style: MacosTheme.of(context).typography.subheadline.copyWith(
      color: MacosColors.systemGrayColor,
    ),
  ),
),
```

# Icons

## MacosIcon

A `MacosIcon` is identical to a regular `Icon` in every way with one exception - it respects
a `MacosTheme`. Use it the same way you would a regular icon:

```dart
MacosIcon(
  CupertinoIcons.add,
  // color: CupertinoColors.activeBlue.color,
  // size: 20,
),
```

# Buttons

## MacosCheckbox

A checkbox is a type of button that lets the user choose between two opposite states, actions, or values. A selected checkbox is considered on when it contains a checkmark and off when it's empty. A checkbox is almost always followed by a title unless it appears in a checklist. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/buttons/checkboxes/)

| Off                                                                                                                   | On                                                                                                                 | Mixed                                                                                                              |
| --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| ![Off Checkbox](https://developer.apple.com/design/human-interface-guidelines/macos/images/CheckBoxes_Deselected.svg) | ![On Checkbox](https://developer.apple.com/design/human-interface-guidelines/macos/images/CheckBoxes_Selected.svg) | ![Mixed Checkbox](https://developer.apple.com/design/human-interface-guidelines/macos/images/CheckBoxes_Mixed.svg) |

Here's an example of how to create a basic checkbox:

```dart
bool selected = false;

MacosCheckbox(
  value: selected,
  onChanged: (value) {
    setState(() => selected = value);
  },
)
```

To make a checkbox in the `mixed` state, set `value` to `null`.

## HelpButton

A help button appears within a view and opens app-specific help documentation when clicked. All help buttons are circular, consistently sized buttons that contain a question mark icon. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/buttons/help-buttons/)

![HelpButton Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/buttonsHelp.png)

Here's an example of how to create a help button:

```dart
HelpButton(
  onPressed: () {
    print('pressed help button'),
  },
)
```

You can customize the help button appearance and behaviour using the `HelpButtonTheme`, but it's not recommended by apple to change help button's appearance.

## RadioButton

A radio button is a small, circular button followed by a title. Typically presented in groups of two to five, radio buttons provide the user a set of related but mutually exclusive choices. A radio button’s state is either on (a filled circle) or off (an empty circle). [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/buttons/radio-buttons/)

![RadioButton Preview](https://developer.apple.com/design/human-interface-guidelines/macos/images/radioButtons.png)

Here's an example of how to create a basic radio button:

```dart
bool selected = false;

MacosRadioButton(
  value: selected,
  onChanged: (value) {
    setState(() => selected = value);
  },
),
```

## PushButton

A push button appears within a view and initiates an instantaneous app-specific action, such as printing a document or deleting a file. Push buttons contain text—not icons—and often open a separate window, dialog, or app so the user can complete a task. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/buttons/push-buttons/)

| Dark Theme                                 | Light Theme                                |
| ------------------------------------------ | ------------------------------------------ |
| <img src="https://imgur.com/GsShoF6.jpg"/> | <img src="https://imgur.com/klWHTAX.jpg"/> |
| <img src="https://imgur.com/v99ekWA.jpg"/> | <img src="https://imgur.com/hj6uGhI.jpg"/> |
| <img src="https://imgur.com/wt0K6u4.jpg"/> | <img src="https://imgur.com/7khWnwt.jpg"/> |
| <img src="https://imgur.com/TgfjJdQ.jpg"/> | <img src="https://imgur.com/83cEMeP.jpg"/> |

Here's an example of how to create a basic push button:

```dart
PushButton(
  child: Text('button'),
  buttonSize: ButtonSize.large,
  onPressed: () {
    print('button pressed');
  },
),
```

## MacosSwitch

A switch is a visual toggle between two mutually exclusive states — on and off. A switch shows that it's on when the accent color is visible and off when the switch appears colorless. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/buttons/switches/)

| On                                         | Off                                        |
| ------------------------------------------ | ------------------------------------------ |
| <img src="https://imgur.com/qK1VCVr.jpg"/> | <img src="https://imgur.com/IBh5jkz.jpg"/> |

Here's an example of how to create a basic toggle switch:

```dart
bool selected = false;

MacosSwitch(
  value: selected,
  onChanged: (value) {
    setState(() => selected = value);
  },
),
```

# Dialogs and Sheets

## MacosAlertDialog

Usage:
```dart
showMacosAlertDialog(
  context: context,
  builder: (_) => MacosAlertDialog(
    appIcon: FlutterLogo(
      size: 56,
    ),
    title: Text(
      'Alert Dialog with Primary Action',
      style: MacosTheme.of(context).typography.headline,
    ),
    message: Text(
      'This is an alert dialog with a primary action and no secondary action',
      textAlign: TextAlign.center,
      style: MacosTheme.of(context).typography.headline,
    ),
    primaryButton: PushButton(
      buttonSize: ButtonSize.large,
      child: Text('Primary'),
      onPressed: () {},
    ),
  ),
);
```

![](https://imgur.com/G3dcjew.png)
![](https://imgur.com/YHtgv59.png)
![](https://imgur.com/xuBR5qK.png)

## MacosSheet

Usage:
```dart
showMacosSheet(
  context: context,
  builder: (_) => const MacosuiSheet(),
);
```

![](https://imgur.com/NV0o5Ws.png)

# Context Menus

macos_ui uses the [native_context_menu] plugin under the hood for Context Menus. 
Please consult the readme for that plugin for usage.

![](https://lesnitsky-images.s3.eu-north-1.amazonaws.com/native_context_menu.gif)

(gif courtesy of the `native_context_menu` plugin)

# Fields

## MacosTextField

A text field is a rectangular area in which the user enters or edits one or more lines of text. A text field can contain plain or styled text.

![](https://developer.apple.com/design/human-interface-guidelines/macos/images/TextFields_PlaceHolder.png)

Here's an example of how to create a basic text field:

```dart
MacosTextField(),
```

# Labels

Labels are a short description of what an element on the screen does.

## MacosTooltip

Tooltips succinctly describe how to use controls without shifting people’s focus away from the primary interface. Help tags appear when the user positions the pointer over a control for a few seconds. A tooltip remains visible for 10 seconds, or until the pointer moves away from the control.

![Tooltip Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/help_Tooltip.png)

To create a tooltip, wrap any widget on a `Tooltip`:

```dart
MacosTooltip(
  message: 'This is a tooltip',
  child: Text('Hover or long press to show a tooltip'),
),
```

You can customize the tooltip the way you want using its `style` property. A tooltip automatically adapts to its environment, responding to touch and pointer events.

# Indicators

## Progress Indicators

Don’t make people sit around staring at a static screen waiting for your app to load content or perform lengthy data processing operations. Use progress indicators to let people know your app hasn't stalled and to give them some idea of how long they’ll be waiting.

Progress indicators have two distinct styles:

- **Bar indicators**, more commonly known as progress bars, show progress in a horizontal bar.
- **Spinning indicators** show progress in a circular form, either as a spinner or as a circle that fills in as progress continues.

People don't interact with progress indicators; however, they are often accompanied by a button for canceling the corresponding operation. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/indicators/progress-indicators/)

![Progress Indicator Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/ProgressIndicators_Lead.png)

### ProgressCircle

A `ProgressCircle` can be either determinate or indeterminate.

| Determinate Progress Circle                | Indeterminate Progress Circle              |
| ------------------------------------------ | ------------------------------------------ |
| <img src="https://imgur.com/hr3dHn9.jpg"/> | <img src="https://imgur.com/NSbKqLK.gif"/> |

Here's an example of how to create an indeterminate progress circle:

```dart
ProgressCircle(
  value: null,
),
```

You can provide a non-null value to `value` to make the progress circle determinate.

### ProgressBar

A `ProgressBar` can only be determinate.

<img src="https://imgur.com/tdYgJmB.jpg" width="50%" height="50%"/>

Here's an example of how to create a determinate progress bar:

```dart
ProgressBar(
  value: 30,
)
```

## Level Indicators

A level indicator graphically represents of a specific value within a range of numeric values. It’s similar to a [slider](#slider) in purpose, but more visual and doesn’t contain a distinct control for selecting a value—clicking and dragging across the level indicator itself to select a value is supported, however. A level indicator can also include tick marks, making it easy for the user to pinpoint a specific value in the range. There are three different level indicator styles, each with a different appearance, for communicating capacity, rating, and relevance.

### CapacityIndicator

A capacity indicator illustrates the current level in relation to a finite capacity. Capacity indicators are often used when communicating factors like disk and battery usage. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/indicators/level-indicators#capacity-indicators)

| Continuous                                                                                                                                     | Discrete                                                                                                                                                                                                         |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![Continuous CapacityIndicator Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/indicators-continous.png)   | ![Discrete CapacityIndicator Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/indicators-discrete.png)                                                                        |
| A horizontal translucent track that fills with a colored bar to indicate the current value. Tick marks are often displayed to provide context. | A horizontal row of separate, equally sized, rectangular segments. The number of segments matches the total capacity, and the segments fill completely—never partially—with color to indicate the current value. |

Here's an example of how to create an interactive continuous capacity indicator:

```dart
double value = 30;

CapacityIndicator(
  value: value,
  discrete: false,
  onChanged: (v) {
    setState(() => value = v);
  },
),
```

You can set `discrete` to `true` to make it a discrete capacity indicator.

### RatingIndicator

A rating indicator uses a series of horizontally arranged graphical symbols to communicate a ranking level. The default symbol is a star.

![RatingIndicator Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/indicator-rating.png)

A rating indicator doesn’t display partial symbols—its value is rounded in order to display complete symbols only. Within a rating indicator, symbols are always the same distance apart and don't expand or shrink to fit the control. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/indicators/level-indicators#rating-indicators)

Here's an example of how to create an interactive rating indicator:

```dart
double value = 3;

RatingIndicator(
  amount: 5,
  value: value,
  onChanged: (v) {
    setState(() => value = v);
  }
)
```

### RelevanceIndicator

A relevance indicator communicates relevancy using a series of vertical bars. It often appears in a list of search results for reference when sorting and comparing multiple items. [Learn more](https://developer.apple.com/design/human-interface-guidelines/macos/indicators/level-indicators#relevance-indicators)

![RelevanceIndicator Example](https://developer.apple.com/design/human-interface-guidelines/macos/images/indicator-relevance.png)

Here's an example of how to create a relevance indicator:

```dart
RelevanceIndicator(
  value: 15,
  amount: 20,
)
```
