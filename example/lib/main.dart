import 'package:flutter/material.dart';
import 'package:horizontal_drag_back_widget/horizontal_drag_back_container.dart';
import 'package:horizontal_drag_back_widget/horizontal_drag_back_parent_widget.dart';
import 'package:horizontal_drag_back_widget/horizontal_drag_back_widget.dart';

import 'package:horizontal_drag_back_widget/horizontal_route_observer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        HorizontalRouteObserver.getInstance(),
      ],
      home: Builder(builder: (context) {
        return Scaffold(
          body: HorizontalDragBackParentWidget(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('First Page'),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              opaque: false,
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder: (context, a1, a2) {
                                return const SecondPage();
                              }));
                    },
                    child: const Text("JUMP"),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HorizontalDragBackContainer(
        child: Builder(
          builder: (context) {
            return Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Second Page'),
                  MaterialButton(
                    onPressed: () {
                      HorizontalDragBackState.of(context)?.pop();
                    },
                    child: const Text("BACK"),
                  )
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
