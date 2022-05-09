import 'dart:core';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(body: Page()),
    );
  }
}

class Page extends StatefulWidget {
  @override
  Content createState() => Content();
}

class Content extends State<Page> {
  GlobalKey _containerKey = GlobalKey();
  String _message = "";

  Content() {
    GestureBinding.instance?.pointerRouter.addGlobalRoute(_handleEvent);
  }

  @override
  void dispose() {
    //See? We're even disposing of things properly. What an elegant solution.
    super.dispose();
    GestureBinding.instance?.pointerRouter.removeGlobalRoute(_handleEvent);
  }

  void _handleEvent(PointerEvent event) {
    var __rb = _containerKey.currentContext?.findRenderObject();
    if (__rb == null) {
      return;
    }
    var _rb = __rb as RenderBox;
    //Make sure it is a stylus event:
    if (event.kind == PointerDeviceKind.stylus) {
      //Convert to the local coordinates:
      Offset coords = _rb.globalToLocal(event.position);

      //Make sure we are inside our component:
      if (coords.dx >= 0 &&
          coords.dx < _rb.size.width &&
          coords.dy >= 0 &&
          coords.dy < _rb.size.height) {
        //Stylus is inside our component and we have its local coordinates. Yay!
        if (event.distance < 100) {
          setState(() {
            _message =
                "dist=${event.distance} x=${coords.dx.toStringAsFixed(1)} y=${coords.dy.toStringAsFixed(1)}";
          });
        } else {
          setState(() {
            _message = "Not a stylus event";
          });
        }
      } else {
        setState(() {
          _message = "Not a stylus event";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          supportZoom: false,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
        ),
        android: AndroidInAppWebViewOptions(
          // setting this to true solves the issue but the view becomes slow.
          // useHybridComposition: true, // blurry and slow ?
          domStorageEnabled: true,
          databaseEnabled: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Test'),
      ),
      body: Column(
        children: [
          Container(
              // don't forget about height
              height: 1100,
              key: _containerKey,
              child:
                  // works, but only if useHybridComposition is true
                  InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://www.google.com")),
                initialOptions: options,
              )
              // Text("Hello")
              ),
          Text(_message)
        ],
      ),
    );
  }
}
