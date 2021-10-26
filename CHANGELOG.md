## [0.10.0]
* New widget - `MacosIcon`! `MacosIcon` is identical to regular icons, with the exception that it respects a `MacosTheme`. Also includes corresponding theme classes
* `MacosThemeData` now sets a global, configurable `iconTheme` for `MacosIcon`s 

## [0.9.3]
* Update to `PushButton`:
  * Added `isSecondary` property

## [0.9.2]
* Nearly all `MouseRegion`s have been updated to use `SystemMouseCursors.basic` in order to more closely adhere to Apple norms
* `mouseCursor` properties have been added to most buttons

## [0.9.1]
* Added top-level theming for `MacosIconButton`
  * Introduces the `MacosIconButtonTheme` InheritedTheme and the `MacosIconButtonThemeData` theme class
* Updates `MacosThemeData` and `MacosIconButton` to use the new `MacosIconButtonThemeData`
* Removes an unnecessary setting of VisualDensity from `MacosThemeData.dark()`

## [0.9.0]
* Added [native_context_menu](https://pub.dev/packages/native_context_menu) as a dependency for native context menus!

## [0.8.2]
* Updates to `MacosListTile`:
  * Added `leadingWhitespace` property
  * Added `onClick` callback
  * Added `onLongPress` callback
  * Added `mouseCursor` property

## [0.8.1]
* Fix the outer border of `MacosSheet` not having a border radius

## [0.8.0]
* New Widget: `MacoSheet`
* New Widget: `MacosListTile`

## [0.7.3]
* Fixed bug where cursor would not change caret location on mouse click

## [0.7.2]
* Upgraded various `copyWith` functions
* Added `==` and `hashCode` to various classes

## [0.7.1]
* Add generics support to `MacosRadioButton` - Thank you [Sacha Arbonel](https://github.com/sachaarbonel)!

## [0.7.0+2]
* Add note in docs that a `Builder` is required for manual sidebar toggling to work.

## [0.7.0+1]
* Fix docs for `PushButtonThemeData`
* Update `dart_code_metrics` dependency

## [0.7.0]
* Adds: `MacosWindow`
* Improved `MacosScaffold`

## [0.6.2]
* Chore: Remove box shadows from `MacosIconButton`

## [0.6.1]
* Fix `builder` property in `MacosApp` never being used ([#148](https://github.com/GroovinChip/macos_ui/issues/148))

## [0.6.0]
* Improved `MacosAlertDialog` design
* Added `showMacosAlertDialog` to display a `MacosAlertDialog` with standard macOS animations and behaviour.
  
## [0.5.2]
* Fixes maximum height issue with `MacosAlertDialog`

## [0.5.1]
* Adds `suppress` widget parameter to `MacosAlertDialog`

## [0.5.0]
* Adds `MacosAlertDialog`

## [0.4.2]
* Add `bottom` Item to `Sidebar`

## [0.4.1]
* Update `MacosColors`
* Fix `Label` alignment

## [0.4.0]
* Adds the `SidebarItem` widget
* Fixes an alignment issue with `MacosTextField`

## [0.3.0]
* Add `MacosPrefix` to widgets/classes with names that overlap with the material/cupertino libraries:
  * `TextField` -> `MacosTextField`
  * `Scaffold` -> `MacosTextField`
  * `IconButton` -> `MacosIconButton`
  * `BackButton` -> `MacosBackButton`
  * `Scrollbar` -> `MacosScrollbar`
  * `Checkbox` -> `MacosCheckbox`
  * `RadioButton` -> `MacosRadioButton`
  * `Tooltip` -> `MacosTooltip`
  * `Typography` -> `MacosTypography`
  * `Switch` -> `MacosSwitch`

## [0.2.4]
* Fix textfield prefix icon alignment

## [0.2.3]
* Add `canvasColor` to `MacosThemeData`. `Scaffold` now uses this as its default background color.

## [0.2.2]
* Add new `MacosColor` and `MacosColors` classes
* Rename `colors.dart` to `macos_dynamic_color`

## [0.2.1]
* `IconButton` updates:
  - The `color` property is now `backgroundColor`
  - The widget now takes a `Widget icon` rather than `IconData iconData` for better control over widget properties
  - Deprecate and remove internal `foregroundColor` value

## [0.2.0]
* New widget: `BackButton`, `IconButton`
* Add `VisualDensity` to `MacosThemeData`
* Ensure localizations get returned in `MacosApp`

## [0.1.4]
* Add `startWidth` properties to `ResizablePane` and `Sidebar`
* Implement `Scrollbar`
* Implement `MacosScrollBehavior`

## [0.1.3]
* Fix `TextField` on Flutter v2.2.0

## [0.1.2]
* Updated the theme api
  * Properties in `MacosThemeData` and in `Typography` can't be null
  * Renamed `DynamicColorX` to `MacosDynamicColor`
  * Added the method `lerp` on all theme datas.

## [0.1.1]
* Implemented `Label` ([#61](https://github.com/GroovinChip/macos_ui/issues/61))
* Capacity Indicator now works as expected ([#49](https://github.com/GroovinChip/macos_ui/issues/49))
* Clear button is now aligned to text ([#82](https://github.com/GroovinChip/macos_ui/issues/82))

## [0.1.0]
* pub.dev release

## [0.0.13]
* Documentation for `ScaffoldScope`

## [0.0.12]
* Implement `Tooltip`
* Add mouse cursors to help button, push button and `TextField`

## [0.0.11]
* Implement `TextField`

## [0.0.10]
* Revamp `Scaffold` [#26](https://github.com/GroovinChip/macos_ui/issues/26)

## [0.0.9+1]
* `CapacityIndicator` colors can now be set on its constructor
* Accessibility support for most of the widgets
* Diagnostics Properties (dev tools) for most of the widgets

## [0.0.9]
* Implemented `HelpButton`
* Fixed [#49](https://github.com/GroovinChip/macos_ui/issues/49)

## [0.0.7]
* Implemented `Checkbox`
* Implemented `RadioButton`

## [0.0.6]
* Update `Typography` with correct letter spacing and font weights
* Add `brightnessOf` and `maybeBrightnessOf` functions to `MacosTheme`

## [0.0.5]
* Adds the `PushButton` widget along with `PushButtonTheme` and `PushButtonThemeData`
* Removes the `height` property from `Typography`'s `TextStyle`s
* Updates `Typography.headline`'s weight and letter spacing

## [0.0.4]
* Major theme refactor that more closely resembles flutter/material and flutter/cupertino
  * The `Style` class is now `MacosThemeData`
  * `MacosTheme` is now a `StatelessWidget` that returns a private `_InheritedMacosTheme`. 
  The static `MacosTheme.of(context)` is now defined here.
  * `MacosApp` now takes a `theme` and `darkTheme` rather than `style` and `darkStyle`. 
  Additionally, there are minor changes to the way `MacosApp` is built that more closely 
  resemble how `MaterialApp` is built. 

## [0.0.3]

* Implemented `Checkbox`
* Implemented `ProgressCircle` and `ProgressBar`
* Implemented the `Switch` widget

## [0.0.2]

* `Scaffold` widget
* Fix `Typography` so that text color is shown appropriately based on Brightness

## [0.0.1]

* Project creation
  * `MacosApp` widget
  * Basic `Typography`
  * Basic theming via `MacosTheme` and `Style`
