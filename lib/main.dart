import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:simple_editor/utils/file_picker.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Simple editor";
    win.show();
  });
  runApp(const MyApp());
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setAsFrameless();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  StreamController<String> streamController = StreamController();

  TextEditingController textController = TextEditingController();

  CustomFilePicker filePicker = CustomFilePicker();
  @override
  void initState() {
    super.initState();

    textController.addListener(_printLatestValue);
    // Start listening to changes.

    streamController.stream
        .debounce(const Duration(seconds: 1))
        .listen((s) async => {
              await filePicker.save(s),
            });
  }

  void _printLatestValue() async {
    if (filePicker.currentFile != null) {
      streamController.add(textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: const Color.fromRGBO(29, 32, 33, 1),
          body: Column(
            children: [
              WindowTitleBarBox(
                child: Row(
                  children: [
                    IconButton(
                        tooltip: "Save as",
                        onPressed: () async {
                          await filePicker.saveAs(textController.text);
                        },
                        icon: const Icon(Icons.save_as, size: 20),
                        color: const Color.fromRGBO(212, 190, 152, 1)),
                    IconButton(
                        tooltip: "Open new file",
                        onPressed: () async {
                          await filePicker.open();
                          textController.text = await filePicker.content!;
                        },
                        icon: const Icon(Icons.file_open_rounded, size: 20),
                        color: const Color.fromRGBO(212, 190, 152, 1)),
                    IconButton(
                        tooltip: "close file",
                        onPressed: () async {
                          if (filePicker.currentFile != null) {
                            await filePicker.close();
                            textController.text = "";
                          }
                        },
                        icon: const Icon(Icons.clear_all_rounded,
                            color: Color.fromRGBO(212, 190, 152, 1))),
                    Expanded(child: MoveWindow()),
                    MinimizeWindowButton(
                        colors: WindowButtonColors(
                            iconNormal:
                                const Color.fromARGB(212, 190, 152, 1))),
                    CloseWindowButton()
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    textAlign: TextAlign.justify,
                    controller: textController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 21,
                      color: Color.fromRGBO(212, 190, 152, 1),
                    ),
                    cursorColor: Colors.pink,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
