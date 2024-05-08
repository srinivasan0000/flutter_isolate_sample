import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.maxFinite),
            const Spacer(),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value,
                  child: const SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: FlutterLogo(
                            size: 180,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: CircularProgressIndicator(),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CircularProgressIndicator(),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            OutlinedButton(
                onPressed: () {
                  int result = heavyTaskWithoutIsolate();
                  showSnackbar(context, "Heavy task without Isolate completed (Count Result: $result)");
                },
                child: const Text("Heavy task withouth Isolate")),
            OutlinedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(withIsolate, receivePort.sendPort);
                  receivePort.listen((total) {
                    showSnackbar(context, "Isolate completed (Total Result: $total)");
                  });
                },
                child: const Text("With Isolate")),
            OutlinedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(isolateWithArgs, [receivePort.sendPort, 1000000000]);
                  receivePort.listen((total) {
                    showSnackbar(context, "Isolate completed (args) (Total Result: $total)");
                  });
                },
                child: const Text("Isolate with args")),
            OutlinedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(isolatesWithRecordArgs, (iteration: 1000000000, sendPort: receivePort.sendPort));
                  receivePort.listen((total) {
                    showSnackbar(context, "Isolate completed, (Records args)  (Total Result: $total)");
                  });
                },
                child: const Text("With Isolate (Record Args)")),
            const Spacer(),
          ],
        ));
  }
}

int heavyTaskWithoutIsolate() {
  int count = 0;
  for (var i = 0; i < 1000000000; i++) {
    count++;
  }
  return count;
}

withIsolate(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }

  sendPort.send(total);
}

int isolateWithArgs(List<dynamic> args) {
  SendPort resultPort = args[0];
  int value = 0;
  for (var i = 0; i < args[1]; i++) {
    value += i;
  }
  Isolate.exit(resultPort, value);
}

isolatesWithRecordArgs(({int iteration, SendPort sendPort}) data) {
  var total = 0.0;
  for (var i = 0; i < data.iteration; i++) {
    total += i;
  }
  data.sendPort.send(total);
}

showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  SnackBar snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
