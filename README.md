<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

An animation library for sliding right back to the previous route

## Features

![Demo](https://github.com/laoge-lol/horizontal_drag_back_widget.git/assets/demo.gif)

## Getting started

```
dependencies:
    horizontal_drag_back_widget: ^lastest
```

## Usage

1.add navigatorObservers

```
navigatorObservers: [
  HorizontalRouteObserver.getInstance(),
],
```
2.First Page add HorizontalDragBackParentWidget
```
HorizontalDragBackParentWidget(
    child: ...
),
```
3.Second page add HorizontalDragBackContainer
```dart
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HorizontalDragBackContainer(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Second Page'),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("BACK"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

## Additional information
child page settings
```
opaque: false
```

