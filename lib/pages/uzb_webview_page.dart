import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UzbWebviewPage extends StatefulWidget {
  const UzbWebviewPage({Key? key}) : super(key: key);

  @override
  _UzbWebviewPageState createState() => _UzbWebviewPageState();
}

class _UzbWebviewPageState extends State<UzbWebviewPage> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  String _currentUrl = "";
  bool _isLoading = true; // Added isLoading state

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _loadSavedWords();
    print(_currentUrl);
    if (_currentUrl != "") {
      setState(() {
        _isLoading = false; // Set isLoading to false when currentUrl is not empty
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSavedWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUrl = prefs.getString('currentUrl') ?? '';
    });
  }

  Future<void> _saveWords(String currentUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUrl', currentUrl);
    setState(() {
      _currentUrl = currentUrl;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        _saveWords(_currentUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(_currentUrl.isNotEmpty ? _currentUrl : "http://ru.tursino.com/"),
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _currentUrl = url.toString();
                        _isLoading = true; // Start loading indicator
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        _currentUrl = url.toString();
                        _isLoading = false; // Stop loading indicator
                      });
                    },
                  ),
                  if (_isLoading) // Show progress indicator if isLoading is true
                    const Center(
                        child: Image(image: AssetImage("assets/images/loading.gif"),)
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Current URL: $_currentUrl',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
