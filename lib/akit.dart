// Copyright© Dokit for Flutter. All rights reserved.
//
// dokit.dart
// Flutter
//
// Created by dokit 0.8.2-nullsafety.10
//

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:akit/engine/akit_binding.dart';
import 'package:akit/kit/apm/crash_kit.dart';
import 'package:akit/kit/apm/log_kit.dart';
import 'package:akit/kit/apm/vm/version.dart';
import 'package:akit/ui/akit_app.dart';
import 'package:akit/ui/akit_btn.dart';
import 'package:akit/ui/kit_page.dart';
import 'package:akit/util/FileOperation.dart';
import 'package:akit/util/time_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as dart;
import 'package:package_info_plus/package_info_plus.dart';

import 'kit/apm/leaks/leaks_doctor.dart';
import 'kit/apm/leaks/leaks_doctor_data.dart';
import 'kit/apm/leaks/leaks_doctor_event.dart';
import 'kit/apm/vm/vm_service_wrapper.dart';
import 'kit/biz/biz.dart';

export 'package:akit/ui/akit_app.dart';

typedef AKitAppCreator = Future<IAKitApp> Function();
typedef LogCallback = void Function(String);
typedef ExceptionCallback = void Function(dynamic, StackTrace);

const String DK_PACKAGE_NAME = 'akit';
const String DK_PACKAGE_VERSION = '0.8.0-nullsafety.0';

//默认release模式不开启该功能
const bool release = kReleaseMode;

//记录当前zone
Zone? _zone;

// ignore: avoid_classes_with_only_static_members
class AKit {
  // 初始化方法,app或者appCreator必须设置一个
  static Future<void> runApp(
      {AKitApp? app,
      bool useRunZoned = true,
      AKitAppCreator? appCreator,
      bool useInRelease = false,
      LogCallback? logCallback,
      ExceptionCallback? exceptionCallback,
      List<String> methodChannelBlackList = const <String>[],
      Function? releaseAction}) async {
    // 统计用户信息，便于了解该开源产品的使用量 (请大家放心，我们不用于任何恶意行为)
    try {
      upLoadUserInfo();
    } catch (e) {
      print('真机可能报异常(可忽略) : upLoadUserInfo ${e.toString()}');
    }

    assert(
        app != null || appCreator != null, 'app and appCreator are both null');
    if (release && !useInRelease) {
      if (releaseAction != null) {
        releaseAction.call();
      } else {
        if (app != null) {
          dart.runApp(app.origin);
        } else {
          dart.runApp((await appCreator!()).origin);
        }
      }
      return;
    }
    blackList = methodChannelBlackList;

    if (useRunZoned != true) {
      var f = () async => <void>{
            _ensureAKitBinding(useInRelease: useInRelease),
            _runWrapperApp(app != null ? app : await appCreator!()),
            _zone = Zone.current
          };
      await f();
      return;
    }
    await runZonedGuarded(
      () async => <void>{
        _ensureAKitBinding(useInRelease: useInRelease),
        _runWrapperApp(app ?? await appCreator!()),
        _zone = Zone.current
      },
      (Object obj, StackTrace stack) {
        _collectError(obj, stack);
        if (exceptionCallback != null) {
          _zone?.runBinary(exceptionCallback, obj, stack);
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          _collectLog(line); //手机日志
          parent.print(zone, line);
          if (logCallback != null) {
            _zone?.runUnary(logCallback, line);
          }
        },
      ),
    );
  }

  /// 暴露出来的除[runApp]外的所有接口
  static final i = _AKitInterfaces._instance;
}

abstract class IAKit {/* Just empty. */}

class _AKitInterfaces extends IAKit with _BizKitMixin, _LeaksDoctorMixin {
  _AKitInterfaces._();

  static final _AKitInterfaces _instance = _AKitInterfaces._();

  late AKitBtnClickedCallback callback = (b) => {};

  /// doKit是否打开了页面（只要是通过doKit打开的页面）
  void isAKitPageShow(AKitBtnClickedCallback callback) {
    this.callback = callback;
  }
}

mixin _BizKitMixin on IAKit {
  /// 更新group信息，详见[addKitGroupTip]
  void updateKitGroupTip(String name, String tip) {
    BizKitManager.instance.updateBizKitGroupTip(name, tip);
  }

  /// 详见[addBizKit]
  void addKit<S extends BizKit>({String? key, required S kit}) {
    BizKitManager.instance.addBizKit<S>(key, kit);
  }

  /// 详见[addBizKits]
  void addBizKits(List<BizKit> bizKits) {
    BizKitManager.instance.addBizKits(bizKits);
  }

  /// 创建BizKit对象
  T newBizKit<T extends BizKit>(
      {String? key,
      required String name,
      String? icon,
      required String group,
      String? desc,
      KitPageBuilder? kitBuilder,
      Function? action}) {
    return BizKitManager.instance.createBizKit(
        name: name,
        group: group,
        key: key,
        icon: icon,
        desc: desc,
        action: action,
        kitBuilder: kitBuilder);
  }

  /// [key] kit的唯一标识，全局不可重复，不传则默认使用[BizKit._defaultKey];
  /// [name] kit显示的名字;
  /// [icon] kit的显示的图标，不传则使用默认图标;
  /// [group] kit归属的组，如果该组不存在，则会自动创建;
  /// [desc] kit的描述信息，不会以任何形式显示出来;
  /// [kitBuilder] kit对应的页面的WidgetBuilder，点击该kit的图标后跳转到的Widget页面，不要求有Navigator，详见[BizKit.tapAction].
  void buildBizKit(
      {String? key,
      required String name,
      String? icon,
      required String group,
      String? desc,
      KitPageBuilder? kitBuilder,
      Function? action}) {
    BizKitManager.instance.buildBizKit(
        key: key,
        name: name,
        icon: icon,
        group: group,
        desc: desc,
        kitBuilder: kitBuilder,
        action: action);
  }
}

mixin _LeaksDoctorMixin on IAKit {
  // 初始化内存泄漏检测功能
  void initLeaks(BuildContext Function() func,
      {int maxRetainingPathLimit = 300}) {
    LeaksDoctor().init(func);
  }

  // 监听内存泄漏结果数据
  void listenLeaksData(Function(LeaksMsgInfo? info)? callback) {
    LeaksDoctor().onLeakedStream.listen((LeaksMsgInfo? info) {
      // print((info?.toString()) ?? '暂未发现泄漏');
      // print('发现泄漏对象实例个数 = ${(info?.leaksInstanceCounts) ?? "0"}');
      if (callback != null) {
        callback(info);
      }
    });
  }

  // 监听内存泄漏节点事件
  void listenLeaksEvent(Function(LeaksDoctorEvent event)? callback) {
    LeaksDoctor().onEventStream.listen((LeaksDoctorEvent event) {
      if (callback != null) {
        callback(event);
      }
    });
  }

  // 添加要观察的对象
  void addObserved(Object obj,
      {String group = 'manual', int? expectedTotalCount}) {
    LeaksDoctor()
        .addObserved(obj, group: group, expectedTotalCount: expectedTotalCount);
  }

  // 触发内存泄漏扫描
  void scanLeaks({String? group, int delay = 500}) {
    LeaksDoctor().memoryLeakScan(group: group, delay: delay);
  }

  // 显示泄漏信息汇总页面
  void showLeaksInfoPage() {
    LeaksDoctor().showLeaksPageWhenClick();
  }
}

// 如果在runApp之前执行了WidgetsFlutterBinding.ensureInitialized，会导致methodchannel功能不可用，可以在runApp前先调用一下ensureAKitBinding
void _ensureAKitBinding({bool useInRelease = false}) {
  if (!release || useInRelease) {
    AKitWidgetsFlutterBinding.ensureInitialized();
  }
}

void _runWrapperApp(IAKitApp wrapper) {
  AKitWidgetsFlutterBinding.ensureInitialized()
// ignore: invalid_use_of_protected_member
    ?..scheduleAttachRootWidget(wrapper)
    ..scheduleWarmUpFrame();
  addEntrance();
}

void _collectLog(String line) {
  LogManager.instance.addLog(LogBean.TYPE_INFO, line);
}

void _collectError(Object? details, Object? stack) {
  LogManager.instance.addLog(
      LogBean.TYPE_ERROR, '${details?.toString()}\n${stack?.toString()}');
  if (CrashLogManager.instance.crashSwitch) {
    var dateTime = DateTime.now();
    FileUtil.shared.writeCounter('carshDoc',
        '[${toDateString(dateTime.millisecondsSinceEpoch)}] ${details.toString()}\n${stack.toString()}');
  }
}

void addEntrance() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final AKitBtn floatBtn = AKitBtn();
    floatBtn.addToOverlay();
    floatBtn.btnClickCallback = AKit.i.callback;
    KitPageManager.instance.loadCache();
  });
}

void dispose({required BuildContext context}) {
  for (final e in aKitOverlayKey.currentState?.widget.initialEntries ?? []) {
    e.remove();
  }
}

Future<void> upLoadUserInfo() async {
  final client = HttpClient();
  // const url = 'https://doraemon.xiaojukeji.com/uploadAppData';
  final request = await client.postUrl(Uri.parse('url'));
  final packageInfo = await PackageInfo.fromPlatform();

  Locale? locale;
  void finder(Element element) {
    if (element.widget is Localizations) {
      locale ??= (element.widget as Localizations).locale;
    } else {
      element.visitChildren(finder);
    }
  }

  AKitApp.appKey.currentContext?.visitChildElements(finder);

  final appId = packageInfo.packageName;
  // 在iOS上可能获取不到appName
  // https://github.com/flutter/flutter/issues/42510
  // 当info.plist文件中只有CFBundleName，没有CFBundleDisplayName时，则无法获取
  final appName =
      packageInfo.appName.isEmpty ? 'AKitFlutterDefault' : packageInfo.appName;
  final appVersion = packageInfo.version;
  const version = DK_PACKAGE_VERSION;
  const from = '1';
  var type = 'flutter_';
  if (Platform.isIOS) {
    type += 'iOS';
  } else if (Platform.isAndroid) {
    type += 'android';
  } else {
    type += 'other';
  }
  final language = locale?.toString() ?? '';
  final playload = <String, dynamic>{};
  await VMServiceWrapper.instance
      .callExtensionService('flutterVersion')
      .then((value) {
    if (value != null) {
      final flutter = FlutterVersion.parse(value.json);
      playload['flutter_version'] = flutter.version;
      playload['dart_sdk_version'] = flutter.dartSdkVersion;
      type +=
          '-flutter_version_${flutter.version}-dart_sdk_version_${flutter.dartSdkVersion}';
    }
  });

  final params = <String, dynamic>{};
  params['appId'] = appId;
  params['appName'] = appName;
  params['appVersion'] = appVersion;
  params['version'] = version;
  params['from'] = from;
  params['type'] = type;
  params['language'] = language;
  params['playload'] = playload;

  request.headers
    ..add('Content-Type', 'application/json')
    ..add('Accept', 'application/json');
  request.add(utf8.encode(json.encode(params)));

  final response = await request.close();
//  final responseBody = await response.transform(utf8.decoder).join();
  if (response.statusCode == HttpStatus.ok) {
//    print('用户统计数据上报成功！');
  }
  client.close();
}
