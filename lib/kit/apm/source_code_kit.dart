import 'dart:convert';

import 'package:akit/akit.dart';
import 'package:akit/kit/apm/apm.dart';
import 'package:akit/kit/apm/vm/vm_helper.dart';
import 'package:akit/kit/kit.dart';
import 'package:akit/widget/source_code/source_code_view.dart';
import 'package:flutter/material.dart';

class SourceCodeKit extends ApmKit {
  @override
  Widget createDisplayPage() {
    return SourceCodePage();
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 120);
  }

  @override
  String getIcon() {
    return 'images/dk_source_code.png';
  }

  @override
  String getKitName() {
    return ApmKitName.KIT_SOURCE_CODE;
  }

  @override
  void start() {}

  @override
  void stop() {}
}

class SourceCodePage extends StatefulWidget {
  @override
  _SourceCodePageState createState() => _SourceCodePageState();
}

class _SourceCodePageState extends State<SourceCodePage> {
  String? sourceCode;

  static const String _akitSourceCodeGroup = 'akit_source_code-group';

  @override
  void dispose() {
    // ignore: invalid_use_of_protected_member
    WidgetInspectorService.instance.disposeGroup(_akitSourceCodeGroup);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var renderObject = findTopRenderObject();
      if (renderObject == null) {
        return;
      }
      WidgetInspectorService.instance.selection.current = renderObject;
      final id = WidgetInspectorService.instance
          // ignore: invalid_use_of_protected_member
          .toId(renderObject.toDiagnosticsNode(), _akitSourceCodeGroup);
      if (id == null) {
        return;
      }
      final String nodeDesc = WidgetInspectorService.instance
          .getSelectedSummaryWidget(id, _akitSourceCodeGroup);
      if (nodeDesc != null) {
        final Map<String, dynamic>? map =
            json.decode(nodeDesc) as Map<String, dynamic>?;
        if (map != null) {
          final Map<String, dynamic>? location =
              map['creationLocation'] as Map<String, dynamic>?;
          if (location != null) {
            final fileLocation = location['file'] as String;
            final fileName = fileLocation.split('/').last;
            getScriptList(fileName).then((value) => {
                  setState(() {
                    sourceCode = value!.source;
                  })
                });
          }
        }
      }
    });
  }

  RenderObject? findTopRenderObject() {
    Element? topElement;
    var context = AKitApp.appKey.currentContext;
    if (context == null) {
      return null;
    }
    final ModalRoute<dynamic>? rootRoute = ModalRoute.of(context);
    void listTopView(Element element) {
      if (element.widget is! PositionedDirectional) {
        if (element is RenderObjectElement &&
            element.renderObject is RenderBox) {
          final ModalRoute<dynamic>? route = ModalRoute.of(element);
          if (route != null && route != rootRoute) {
            topElement = element;
          }
        }
        element.visitChildren(listTopView);
      }
    }

    context.visitChildElements(listTopView);
    if (topElement != null) {
      return topElement!.renderObject;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: sourceCode == null
          ? const Center(
              child: Text('加载中'),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SourceCodeView(sourceCode: sourceCode ?? ''),
            ),
    );
  }
}
