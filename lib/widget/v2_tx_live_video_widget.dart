import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:live_flutter_plugin/v2_tx_live_def.dart';

class V2TXLiveVideoWidget extends StatefulWidget {
  final ValueChanged<int>? onViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const V2TXLiveVideoWidget(
      {Key? key, this.onViewCreated, this.gestureRecognizers}) :super(key: key);

  @override
  State<StatefulWidget> createState() => V2TXLiveVideoWidgetState();
}

class V2TXLiveVideoWidgetState extends State<V2TXLiveVideoWidget> {
  final String _viewType = V2TXLiveRenderView.renderViewType;
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: _viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
      );
    } else {
      return const Center(
        child: Text(
          "This platform does not support platform View",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel("tx_Live_video_view_$id");
    if (widget.onViewCreated != null) {
      widget.onViewCreated!(id);
    }
  }

  @override
  void dispose() {
    debugPrint("V2TXLiveVideoWidgetState dispose");
    _channel?.invokeMethod("destroyRenderView");
    super.dispose();
  }
}