// Copyright© Dokit for Flutter. All rights reserved.
//
// aKit_app.dart
// Flutter
//

import 'package:akit/kit/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final GlobalKey<OverlayState> aKitOverlayKey = GlobalKey<OverlayState>();

abstract class IAKitApp extends Widget {
  Widget get origin;
}

// 谷歌提供的DevTool会判断入口widget是否在主工程内申明(runApp(MyApp())，MyApp必须在主工程内定义，估计是根据source file来判断的)，
// 如果在package内去申明这个入口widget，则在Flutter Inspector上的左边树会被折叠，影响开发使用。故这里要求在main文件内使用AKitApp(MyApp())的形式来初始化入口
class AKitApp extends StatefulWidget implements IAKitApp {
  AKitApp(Widget widget)
      : _origin = _AKitWrapper(widget),
        super(key: rootKey);

  // 放置aKit悬浮窗的容器
  static GlobalKey rootKey = GlobalKey();

  // 放置应用真实widget的容器
  static GlobalKey appKey = GlobalKey();

  @override
  Widget get origin => _origin;
  final Widget _origin;

  @override
  State<StatefulWidget> createState() {
    return _AKitAppState();
  }
}

class _AKitWrapper extends StatelessWidget {
  _AKitWrapper(this._origin) : super(key: AKitApp.appKey);

  final Widget _origin;

  @override
  Widget build(BuildContext context) {
    if (_origin is StatelessWidget) {
      debugPrint(_origin.toStringShort());
      Widget widget = (_origin as StatelessWidget).build(context);
      debugPrint(widget.toStringShort());
      if (widget is MaterialApp) {
        final navigatorObservers = widget.navigatorObservers;
        if (navigatorObservers != null) {
          ensureAkitObserver(navigatorObservers);
          return widget;
        }
      }
      if (widget is CupertinoApp) {
        final navigatorObservers = widget.navigatorObservers;
        if (navigatorObservers != null) {
          ensureAkitObserver(navigatorObservers);
          return widget;
        }
      }
    }
    return _origin;
  }

  void ensureAkitObserver(List<NavigatorObserver> navigatorObservers) {
    if (!navigatorObservers
        .any((element) => element is AKitNavigatorObserver)) {
      navigatorObservers.add(AKitNavigatorObserver());
    }
  }
}

class _AKitAppState extends State<AKitApp> {
  final List<OverlayEntry> entries = <OverlayEntry>[];
  final List<Locale> supportedLocales = const <Locale>[Locale('en', 'US')];

  @override
  void initState() {
    super.initState();
    entries.clear();
    entries.add(OverlayEntry(builder: (BuildContext context) {
      return widget.origin;
    }));
  }

  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
    yield DefaultMaterialLocalizations.delegate;
    yield DefaultCupertinoLocalizations.delegate;
    yield DefaultWidgetsLocalizations.delegate;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: <Widget>[
          widget.origin,
          _MediaQueryFromWindow(
            child: Localizations(
              locale: supportedLocales.first,
              delegates: _localizationsDelegates.toList(),
              child: ScaffoldMessenger(
                child: Overlay(key: aKitOverlayKey),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MediaQueryFromWindow extends StatefulWidget {
  const _MediaQueryFromWindow({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _MediaQueryFromWindowsState createState() => _MediaQueryFromWindowsState();
}

class _MediaQueryFromWindowsState extends State<_MediaQueryFromWindow>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // ACCESSIBILITY

  @override
  void didChangeAccessibilityFeatures() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  // METRICS

  @override
  void didChangeMetrics() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  @override
  void didChangeTextScaleFactor() {
    setState(() {
      // The textScaleFactor property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  // RENDERING
  @override
  void didChangePlatformBrightness() {
    setState(() {
      // The platformBrightness property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
