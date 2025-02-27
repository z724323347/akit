import 'package:akit/akit.dart';
import 'package:akit/kit/apm/apm.dart';
import 'package:akit/ui/resident_page.dart';
import 'package:flutter/material.dart';

// AKitBtn 点击事件回调
// 参数说明：
// true : akit面板展开
// false: akit面板收起
typedef AKitBtnClickedCallback = void Function(bool);

// 入口btn
// ignore: must_be_immutable
class AKitBtn extends StatefulWidget {
  AKitBtn() : super(key: aKitBtnKey);

  static GlobalKey<AKitBtnState> aKitBtnKey = GlobalKey<AKitBtnState>();
  OverlayEntry? overlayEntry;
  AKitBtnClickedCallback? btnClickCallback;

  @override
  AKitBtnState createState() => AKitBtnState(overlayEntry!);

  void addToOverlay() {
    assert(overlayEntry == null);
    overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return this;
    });
    final OverlayState? rootOverlay = aKitOverlayKey.currentState;
    assert(rootOverlay != null);
    rootOverlay?.insert(overlayEntry!);
    ApmKitManager.instance.startUp();
  }
}

class AKitBtnState extends State<AKitBtn> {
  AKitBtnState(this.owner);

  Offset? offsetA; //按钮的初始位置
  final OverlayEntry owner;
  OverlayEntry? debugPage;
  bool showDebugPage = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offsetA?.dx,
      top: offsetA?.dy,
      right: offsetA == null ? 20 : null,
      bottom: offsetA == null ? 120 : null,
      child: Draggable(
        feedback: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              // style: ButtonStyle(
              //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
              // ),
              onTap: openDebugPage,
              // style: ButtonStyle(
              //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
              // ),
              child: Image.asset('images/dokit_flutter_btn.png',
                  package: DK_PACKAGE_NAME, height: 70, width: 70),
            ),
          ),
        ),
        childWhenDragging: Container(),
        onDragEnd: (DraggableDetails detail) {
          final Offset offset = detail.offset;
          setState(() {
            final Size size = MediaQuery.of(context).size;
            final double width = size.width;
            final double height = size.height;
            double x = offset.dx;
            double y = offset.dy;
            if (x < 0) {
              x = 0;
            }
            if (x > width - 80) {
              x = width - 80;
            }
            if (y < 0) {
              y = 0;
            }
            if (y > height - 26) {
              y = height - 26;
            }
            offsetA = Offset(x, y);
          });
        },
        onDraggableCanceled: (Velocity velocity, Offset offset) {},
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              // style: ButtonStyle(
              //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
              // ),
              onTap: openDebugPage,
              // style: ButtonStyle(
              //   padding: MaterialStateProperty.all(EdgeInsets.all(0)),
              // ),
              child: Image.asset('images/dokit_flutter_btn.png',
                  package: DK_PACKAGE_NAME, height: 70, width: 70),
            ),
          ),
        ),
      ),
    );
  }

  void openDebugPage() {
    debugPage ??= OverlayEntry(builder: (BuildContext context) {
      return ResidentPage();
    });
    if (showDebugPage) {
      closeDebugPage();
    } else {
      aKitOverlayKey.currentState?.insert(debugPage!, below: owner);
      showDebugPage = true;
    }
    widget.btnClickCallback!(showDebugPage);
  }

  void closeDebugPage() {
    if (showDebugPage && debugPage != null) {
      debugPage!.remove();
      showDebugPage = false;
    }
  }
}
