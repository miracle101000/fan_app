import 'dart:convert';

import 'package:advertising_id/advertising_id.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:carrier_info/carrier_info.dart';
import 'package:fan_app/user_data.dart';
import 'package:fan_app/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? analyticsID = '',
      token = '',
      advertisingId = '',
      installReferrer = '',
      countryCode = '',
      currentUrl = '';

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  // PullToRefreshController? pullToRefreshController;

  String baseUrl = "https://blzcasn.xyz";
  bool isLoading = true;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  CookieManager cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    init().then((value) {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _saveCurrentUrl(currentUrl);
    _setCookies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              height: 56 + MediaQuery.of(context).viewPadding.top,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1.5))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SafeArea(
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/icon.png",
                          height: 50,
                          width: 50,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: MyText(
                            text: "Фан-клуб",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            )),
        body: Stack(
          children: [
            if (!isLoading)
              SafeArea(
                  child: Column(children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                            URLRequest(url: WebUri(_req().toString())),
                        initialSettings: settings,
                        // pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) async {
                          webViewController = controller;
                          await _getCookies(webViewController, () async {
                            await cookieManager.setCookie(
                                url: WebUri(baseUrl),
                                name: "SessionID",
                                value: DateTime.now().toIso8601String(),
                                webViewController: webViewController);
                          });
                          await _getSession();
                          await _getLocal();
                        },
                        onLoadStart: (controller, url) {
                          print(url);
                          setState(() {
                            this.url = url.toString();
                            currentUrl = url.toString();
                          });
                        },
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                              resources: request.resources,
                              action: PermissionResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunchUrl(uri)) {
                              // Launch the App
                              await launchUrl(uri);
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          // pullToRefreshController?.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                          });
                        },
                        onReceivedError: (controller, request, error) {
                          // pullToRefreshController?.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            // pullToRefreshController?.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                          });
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          if (kDebugMode) {
                            print(consoleMessage);
                          }
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(
                              value: progress,
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(100),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  height: 56 + MediaQuery.of(context).viewPadding.bottom,
                  color: Colors.white,
                  // decoration: const BoxDecoration(
                  //     border: Border(top: BorderSide(color: Colors.black))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _item(
                            child: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onTap: () {
                              webViewController?.goBack();
                            },
                          ),
                          _item(
                            child: const Icon(Icons.arrow_forward),
                            onTap: () {
                              webViewController?.goForward();
                            },
                          ),
                          _item(
                            child: const Icon(Icons.refresh),
                            onTap: () {
                              webViewController?.reload();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])),
            if (isLoading || progress < 1.0)
              Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 20,
                              width: (MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: LinearGradient(colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade300,
                                  ])),
                            ),
                            Container(
                              height: 20,
                              width:
                                  (MediaQuery.of(context).size.width * 0.75) *
                                      progress,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const LinearGradient(colors: [
                                    Colors.black38,
                                    Colors.black,
                                  ])),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            text: "${progress * 100}%",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16),
                      ],
                    )
                  ],
                ),
              )
          ],
        ));
  }

  _item({required Widget child, required void Function() onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black, width: 1.5)),
          child: child,
        ));
  }

  Future init() async {
    currentUrl = UserData.currentUrl;
    await _initFirebase();
    await _getToken();
    await _getGaid();
    await _installReferer();
    await _getCountry();
  }

  Uri _req() {
    return Uri.https("blzcasn.xyz", '/index.php', {
      "gaid": advertisingId,
      "fcmToken": token,
      "country": countryCode?.toUpperCase(),
      "installReferrer": Uri.encodeComponent(installReferrer ?? "")
    });
  }

  Future<void> _saveCurrentUrl(String? url) async {
    if (url != null) {
      UserData.currentUrl = url;
    }
  }

  _setCookies() async {
    List<Cookie> cookies = await cookieManager.getAllCookies();
    UserData.cookies =
        cookies.map<String>((e) => json.encode(e.toJson())).toList();
    List<WebStorageItem> sessionStorage =
        await webViewController!.webStorage.sessionStorage.getItems();
    UserData.sessionStorage =
        sessionStorage.map((e) => json.encode(e.toJson())).toList();
    List<WebStorageItem> local =
        await webViewController!.webStorage.localStorage.getItems();
    UserData.localStorage = local.map((e) => json.encode(e.toJson())).toList();
  }

  _getCookies(InAppWebViewController? controller,
      Future<void> Function() callback) async {
    var cookies = UserData.cookies
        .toList()
        .map<Cookie?>((e) => Cookie.fromMap(json.decode(e)))
        .toList();
    List<Future> future = [];

    for (Cookie? cookie in cookies) {
      future.add((() async => await cookieManager.setCookie(
          url: WebUri(baseUrl),
          name: cookie!.name,
          value: cookie.value,
          webViewController: webViewController))());
    }
    if (future.isNotEmpty) {
      await Future.wait(future);
    } else {
      await callback();
    }
  }

  _getSession() async {
    var sessions = UserData.sessionStorage
        .toList()
        .map<WebStorageItem?>((e) => WebStorageItem.fromMap(json.decode(e)))
        .toList();
    List<Future> future = [];
    for (WebStorageItem? session in sessions) {
      future.add((() async => await webViewController!.webStorage.sessionStorage
          .setItem(key: session!.key!, value: session.value))());
    }
  }

  _getLocal() async {
    var locals = UserData.localStorage
        .toList()
        .map<WebStorageItem?>((e) => WebStorageItem.fromMap(json.decode(e)))
        .toList();
    List<Future> future = [];
    for (WebStorageItem? session in locals) {
      future.add((() async => await webViewController!.webStorage.localStorage
          .setItem(key: session!.key!, value: session.value))());
    }
  }

  Future _initFirebase() async {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analyticsID = (await analytics.appInstanceId) ?? "";
    return analyticsID;
  }

  Future _getToken() async {
    token = (await FirebaseMessaging.instance.getToken()) ?? "";
  }

  Future _getGaid() async {
    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      advertisingId ??= '';
    }

    return advertisingId ?? "";
  }

  Future _installReferer() async {
    ReferrerDetails referrerDetails =
        await AndroidPlayInstallReferrer.installReferrer;
    installReferrer = referrerDetails.installReferrer ?? "";
  }

  Future _getCountry() async {
    try {
      AndroidCarrierData? carrierInfo = await CarrierInfo.getAndroidInfo();
      if (carrierInfo != null && carrierInfo.telephonyInfo.isNotEmpty) {
        countryCode = carrierInfo.telephonyInfo[0].networkCountryIso.toUpperCase();
        print("HERE ${countryCode}");

      }
    } catch (_) {
      countryCode = "RU";
    }
    return countryCode;
  }
}
