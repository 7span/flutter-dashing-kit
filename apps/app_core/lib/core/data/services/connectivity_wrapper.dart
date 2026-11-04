import 'dart:async';

import 'package:app_core/core/data/services/connectivity_service.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({
    required this.child,
    required this.connectivityService,
    super.key,
  });

  final Widget child;
  final ConnectivityService connectivityService;

  @override
  ConnectivityWrapperState createState() => ConnectivityWrapperState();
}

class ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    widget.connectivityService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: widget.child);
  }

  @override
  void dispose() {
    unawaited(widget.connectivityService.dispose());
    super.dispose();
  }
}
