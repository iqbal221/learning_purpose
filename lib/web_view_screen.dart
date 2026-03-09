import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebveiwScreen extends StatefulWidget {
  const WebveiwScreen({super.key});

  @override
  State<WebveiwScreen> createState() => _WebveiwScreenState();
}

class _WebveiwScreenState extends State<WebveiwScreen> {
  InAppWebViewController? _controller;
  double _progress = 0;
  final homeUrl = WebUri("https://my-apps-five.vercel.app/");
  late final PullToRefreshController _pullToRefreshController;

  Future<void> _goBack() async {
    if (_controller == null) return;

    final canBack = await _controller!.canGoBack();
    if (canBack) {
      await _controller!.goBack();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("NO Previous page")));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(enabled: true),
      onRefresh: () async {
        if (_controller == null) {
          _pullToRefreshController.endRefreshing();
          return;
        }

        if (await _controller!.getUrl() != null) {
          await _controller!.reload();
        } else {
          await _controller!.loadUrl(urlRequest: URLRequest(url: homeUrl));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ostad App"),
        leading: IconButton(onPressed: _goBack, icon: Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            onPressed: () => _controller?.reload(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 1) LinearProgressIndicator(value: _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: homeUrl),
              pullToRefreshController: _pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowFileAccess: true,
                mediaPlaybackRequiresUserGesture: true,
                supportZoom: true,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100);
              },
              onLoadStop: (controller, url) async {
                _pullToRefreshController.endRefreshing();
              },
            ),
          ),
        ],
      ),
    );
  }
}
