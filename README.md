# AKit Flutter版

内测版本，目前提供了日志、method channel信息、路由信息、网络抓包、帧率、设备与内存信息查看、控件信息查看、颜色拾取、启动耗时、查看源码、查看widget的build链以及对齐标尺的功能.

## 支持flutter版本
1. 已升级适配 flutter 3.7.12
2. ~~version>=1.17.5，其余版本未做过兼容性测试。支持flutter2.0的分支为`0.8.0-nullsafety.0`，后期维护主要会基于该版本进行~~。

## Pub地址 (来自 DoKit 插件 `0.8.0-nullsafety.0`)
[DoKit For Flutter](https://pub.dev/packages/dokit)

## 接入
在pubspect.yaml文件的dependencies节点添加pub依赖

```
dependencies:
  akit: any
```

在main函数入口初始化。 AKit使用runZone的方式进行日志捕获，方法通道的捕获，如果你的app需要使用同样的方式会有冲突。

```
void main() => {

      AKit.runApp(app:AKitApp(MyApp()),
          // 是否在release包内使用，默认release包会禁用
          useInRelease: true,
          // 选择性控制是否使用akit中的runZonedGuarded,false: 禁用；true: 启用
          useRunZoned: false,
          releaseAction: () => {
              // release模式下执行该函数，一些用到runZone之类实现的可以放到这里，该值为空则会直接调用系统的runApp(MyApp())，
              })
    };
}

```

**注：谷歌提供的DevTool会折叠非主工程内实例化的widget（根据source file是否属于当前工程），AKit需要实例化一个wrapper widget用以展示各种overlay，
      如果在package内去声明这个wrapper，会导致左边树全部被折叠。故这里要求在main文件内使用AKitApp(MyApp())的方式来初始化入口**


 另外提供了一个异步创建入口Widget的方式，需要异步构建widget的情况。(有些库会在异步构建Widget的时候调用WidgetFlutterBinding.ensureInitialized()，影响AKit的method channel监控
 和日志监控，需要延迟到runZone内执行)
```
void main() => {
       AKit.runApp(
             appCreator: () async =>
                 AKitApp(await crateApp())));
    };

 Widget crateApp() async{
   // 一些初始化操作
   await ...
   return MyApp();
 }
}
```


### 参数说明


参数 | 返回类型 | 说明 | 是否必须
---|---|---|---
app | AKitApp | 返回被AKitApp类包装的根布局 | app和appCreator至少需要设置一个同时设置时app参数生效
appCreator | AKitAppCreator | 异步返回根布局 | 同上
useInRelease | bool |是否在release模式下显示AKit | x
logCallback | LogCallback | 调用print方法打印日志时被回调 | x
exceptionCallback | ExceptionCallback | 异常回调 | x
methodChannelBlackList | List<String> | 过滤方法通道的黑名单 | x
releaseAction | Function | release模式下执行该函数，该值为空则会直接调用系统的runApp |x


## 功能简介

### 全部组件

<img src="https://pt-starimg.didistatic.com/static/starimg/img/AuETMp2dp11619684586454.png"  width="300px"  />

当前版本AKit支持的所有功能全览。常驻工具为显示在底部tab栏的组件，可通过拖动将组件放置或移出常驻工具。


### 日志查看

<img src="https://pt-starimg.didistatic.com/static/starimg/img/apwIxs7A341609765573351.jpg"  width="300px"  />


查看使用print方式打印出来的日志，捕获的异常会以红色显示。超过7行的日志会自动折叠，点击可展开。长按复制日志到剪贴板。


### 网络请求

<img src="https://pt-starimg.didistatic.com/static/starimg/img/nEN7uos9OV1609765604202.jpg"  width="300px"  />


可以捕获通过flutter httpclient发出的网络请求，主流的http、dio库底层也是通过httpclient实现的，也能捕获。


### Method Channel信息

<img src="https://pt-starimg.didistatic.com/static/starimg/img/qH6jtyNvqp1609765652146.jpg"  width="300px"  />


可以展示从dart端到native和从native端到dart端的方法调用、参数、返回结果。

### 路由信息

<img src="https://pt-starimg.didistatic.com/static/starimg/img/VLyiReklD41609765682140.jpg"  width="300px"  />


展示当前页面的路由信息，当存在多层Navigator组件嵌套时，会展示多层的路由信息。

**注：当前查找栈顶widget是通过遍历整棵widget tree的方式，如果添加了overlay，栈顶widget会始终指向overlay，导致该功能读取数据异常。**


### 帧率

<img src="https://pt-starimg.didistatic.com/static/starimg/img/Xno9FVbweg1609765703740.jpg"  width="300px"  />


展示最近240帧的耗时情况，每次进入该页面刷新。debug模式下帧率会普遍偏高，profile和release模式下会比较正常。

### 内存

<img src="https://pt-starimg.didistatic.com/static/starimg/img/9ESwEmODlR1609765729941.jpg"  width="300px"  />


当前已使用的内存和最大内存；底部搜索栏可以显示指定的类的对象数量和占用内存。

**注：该功能通过VMService获取数据，release模式下无法使用**

### 基本信息

<img src="https://pt-starimg.didistatic.com/static/starimg/img/8brZZzWijZ1609765750681.jpg"  width="300px"  />


展示当前dart虚拟机进程、cpu、版本信息；当前app包名和dart工程构建版本信息；

**注：该功能通过VMService获取数据，release模式下无法使用。flutter版本号需要flutter attach后才可获取**

### 控件检查
<img src="https://pt-starimg.didistatic.com/static/starimg/img/qXec9UMCfi1619673904927.png"  width="300px"  />

查看当前页面上的控件信息，包含位置、大小、源码信息、对齐标尺和查看build链等。

**注：源码信息只有在debug模式下才可获取到。同路由功能，在存在Overlay的情况下功能会异常**

### 颜色拾取
<img src="https://pt-starimg.didistatic.com/static/starimg/img/4MYRNqqcZh1619673900891.png"  width="300px"  />

查看当前页面任何位置对应的像素点的RGBA颜色值，方便UI的调试和获取像素点的颜色

### Widget层级
<img src="https://pt-starimg.didistatic.com/static/starimg/img/GmjvVDp4Ye1619673908393.png"  width="300px"  />
<img src="https://pt-starimg.didistatic.com/static/starimg/img/sGd73y7uoc1619673910771.png"  width="300px"  />

查看当前选中widget的树层级，以及它renderObject的详细build链等信息

### 页面源码查看
<img src="https://pt-starimg.didistatic.com/static/starimg/img/e7Pbo95nJ71619665430550.jpg"  width="300px"  />

查看当前所在页面的源代码，支持语法高亮显示

**注：源码信息只有在debug模式下才可获取到。同路由功能，在存在Overlay的情况下功能会异常**

### 页面启动耗时
<img src="https://pt-starimg.didistatic.com/static/starimg/img/gDkBh4a87P1619673916288.png"  width="300px"  />
<img src="https://pt-starimg.didistatic.com/static/starimg/img/z1wWlYqZDg1619674872051.png"  width="300px"  />

获取页面的启动耗时, 
框架已做无侵入的注入NavigatorObserver。但是在较复杂的App构建时可能失效，需要手动添加`AkitNavigatorObserver`

**注：页面启动耗时信息只有在profile或release模式下才有意义**

### 自定义入口
<img src="https://pt-starimg.didistatic.com/static/starimg/img/0b2jdWmxbK1637739570393.png" width="300px">

业务方可以依照自己需要，依托自定义入口的功能（支持添加多组），在akit中添加自己的功能启动入口。比如上图中的“业务专区”。



