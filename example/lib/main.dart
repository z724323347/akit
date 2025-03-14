// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:akit/akit.dart';
import 'package:akit/kit/apm/leaks/leaks_doctor_observer.dart';
import 'package:akit/kit/apm/vm/vm_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'page2.dart';

void main() {
  List<String> blackList = [
    'plugins.flutter.io/sensors/gyroscope',
    'plugins.flutter.io/sensors/user_accel',
    'plugins.flutter.io/sensors/accelerometer'
  ];

  AKit.runApp(
      app: AKitApp(MyApp()),
      useInRelease: true,
      useRunZoned: false,
      logCallback: (log) {
//        String i = log;
      },
      methodChannelBlackList: blackList,
      exceptionCallback: (dynamic obj, StackTrace trace) {
        print('ttt$obj');
      });
  // runApp(MyApp());

  AKit.i.isAKitPageShow((bool isShow) {
    print('isShow = $isShow');
  });

  // 业务方接入自定义能力
  AKit.i.buildBizKit(
      name: 'toB',
      group: '业务专区',
      desc: '[提供自动化测试能力]',
      action: () => {print('isShow = 业务专区 toB')});

  AKit.i.buildBizKit(
      name: 'toC',
      group: '业务专区',
      desc: '[提供自动化测试能力]',
      action: () => {print('isShow = 业务专区 toB')});

  AKit.i.buildBizKit(
      name: 'toC1',
      group: '业务专区1',
      desc: '[提供自动化测试能力1]',
      action: () => {print('isShow = 业务专区 toB')});

  AKit.i.buildBizKit(
      name: '内存检测',
      group: '业务专区4',
      desc: '[提供触发内存泄漏扫描能力]',
      action: () {
        print('提供触发内存泄漏扫描能力');
        AKit.i.scanLeaks();
      });

  AKit.i.buildBizKit(
      name: 'toC2',
      group: '业务专区1',
      desc: '[提供自动化测试能力1]',
      kitBuilder: () => BizKitTestPage());

  var bizKit0 = AKit.i.newBizKit(name: '1111', group: '业务专区2');
  AKit.i.addKit(kit: bizKit0);

  var bizKit1 = AKit.i.newBizKit(name: '2222', group: '业务专区3');
  var bizKit2 = AKit.i.newBizKit(name: '3333', group: '业务专区3');
  var bizKit3 = AKit.i.newBizKit(name: '4444', group: '业务专区3');
  AKit.i.addBizKits([bizKit1, bizKit2, bizKit3]);

  // AKit.i.addKit({kit: BizKit(name: '1111', group: '业务专区2')});
}

/// ===自定义BizKit Test===
class BizKitTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BizKitTestPageState();
  }
}

class BizKitTestPageState extends State<BizKitTestPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              height: 44,
              child: Row(
                children: [
                  Text('自定义BizKit Test Page',
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'PingFang SC',
                          fontSize: 14))
                ],
              )),
          Divider(
            height: 0.5,
            color: Color(0xffdddddd),
            indent: 16,
            endIndent: 16,
          )
        ],
      ),
    );
  }
}

/// === end ===

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKit Test',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the kit.visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [
        LeaksDoctorObserver(
            shouldCheck: (route) {
              return route.settings.name != '/';
            },
            confPolicyPool: () => {'TestPage2': 1}),
      ],
      home: AKitTestPage(),
    );
  }
}

class AKitTestPage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _AKitTestPageState createState() => _AKitTestPageState();
}

class _AKitTestPageState extends State<AKitTestPage> {
  @override
  void initState() {
    super.initState();

    // 内存泄漏检测初始化
    AKit.i.initLeaks(() => context, maxRetainingPathLimit: 300);
    AKit.i.listenLeaksEvent((event) {
      print(event);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                child: Text('Mock Http Post',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: mockHttpPost,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Mock Http Get',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: mockHttpGet,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Test Download',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: testDownload,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Test Method Channel',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: () {
                  testMethodChannel();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Open Route Page',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.of(context, rootNavigator: false).push<void>(
                      MaterialPageRoute(
                          builder: (context) {
                            //指定跳转的页面
                            return TestPage2();
                          },
                          settings: RouteSettings(
                              name: 'page1', arguments: ['test', '111'])));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Test Get Page Script',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: () {
                  VmHelper.instance.testPrintScript();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('Stop Timer',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: stopAll,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: InkWell(
                // style: ButtonStyle(
                //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // ),
                child: Text('打开新页面',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onTap: openPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Timer? timer;

  void testDownload() async {
    String url =
        'https://pt-starfile.didistatic.com/static/starfile/node20210220/895f1e95e30aba5dd56d6f2ccf768b57/GjzGU0Pvv11613804530384.zip';
    String? savePath = await getPhoneLocalPath();
    String zipName = 'test.zip';
    Dio dio = Dio();
    print("$savePath/$zipName");
    Response response = await dio.download(url, "$savePath/$zipName",
        onReceiveProgress: (received, total) {
      if (total != -1) {
        // 当前下载的百分比
        // print((received / total * 100).toStringAsFixed(0) + "%");
        // print("received=$received total=$total");
        if (received == total) {
          print("下载完成 ✅ ");
        }
      } else {}
    });
  }

  ///获取手机的存储目录路径
  ///getExternalStorageDirectory() 获取的是  android 的外部存储 （External Storage）
  ///  getApplicationDocumentsDirectory 获取的是 ios 的Documents` or `Downloads` 目录
  Future<String?> getPhoneLocalPath() async {
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }

  void testMethodChannel() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      const MethodChannel _kChannel =
          MethodChannel('plugins.flutter.io/package_info');
      final Map<String, dynamic>? map =
          await _kChannel.invokeMapMethod<String, dynamic>('getAll');
    });
  }

  void openPage() {
    Navigator.of(context, rootNavigator: false).push<void>(MaterialPageRoute(
        builder: (context) {
          //指定跳转的页面
          return TestPage2();
        },
        settings: RouteSettings(name: 'page1', arguments: ['test', '111'])));
  }

  void stopAll() {
    print('stopAll');
    timer?.cancel();
    timer = null;
  }

  void request() async {
    Image.network(
      //图片地址
      'https://img04.sogoucdn.com/app/a/100520093/ac75323d6b6de243-0bd502b2bdc1100a-92cef3b2299cfc6875afe7d5d0b83a7b.jpg',
      //填充模式
      fit: BoxFit.fitWidth,
    );
  }

  void mockHttpPost() async {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      HttpClient client = HttpClient();
      String url = 'https://pinzhi.didichuxing.com/kop_stable/gateway?api=hhh';
      HttpClientRequest request = await client.postUrl(Uri.parse(url));
      Map<String, String> map1 = Map();
      map1["v"] = "1.0";
      map1["month"] = "7";
      map1["day"] = "25";
      map1["key"] = "bd6e35a2691ae5bb8425c8631e475c2a";
      request.add(utf8.encode(json.encode(map1)));
      request.add(utf8.encode(json.encode(map1)));
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
    });
  }

  void mockHttpGet() async {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      HttpClient client = HttpClient();
      String url = 'https://www.baidu.com';
      HttpClientRequest request = await client.postUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
    });
  }
}

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => {
                Navigator.of(context, rootNavigator: false).push<void>(
                    MaterialPageRoute(
                        builder: (context) {
                          //指定跳转的页面
                          return TestPage2();
                        },
                        settings: RouteSettings(
                            name: 'page1', arguments: ['test', '111'])))
              },
              child: Text(
                'page1:',
              ),
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            ),
            Container(height: 100, width: 300)
          ],
        ),
      ),
    );
  }
}

class TestPage3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestPageState3();
  }
}

class TestPageState3 extends State<TestPage3> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => {
                Navigator.of(context, rootNavigator: false)
                    .push<void>(MaterialPageRoute(
                        builder: (context) {
                          //指定跳转的页面
                          return MyApp();
                        },
                        settings: RouteSettings(name: 'page3')))
              },
              child: Text(
                'page3:',
              ),
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            )
          ],
        ),
      ),
    );
  }
}
