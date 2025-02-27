import 'package:flutter/material.dart';

class WidgetDetailsPage extends StatelessWidget {
  final Element element;

  const WidgetDetailsPage({Key? key, required this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(children: [
            const TextSpan(
                text: 'Widget Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            WidgetSpan(child: SizedBox(width: 10)),
            TextSpan(
                text: 'depth:${element.depth}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
        ),
        leading: GestureDetector(
          onTap: () => _onBack(context),
          child: const Icon(
            Icons.chevron_left,
            size: 28,
          ),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Widget Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 0.5,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    element.widget.toStringDeep(),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RenderObject Full Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 0.5,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    element.renderObject?.toStringDeep() ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
