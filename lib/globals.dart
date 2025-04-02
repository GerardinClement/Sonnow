import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final libraryRefreshNotifier = ValueNotifier<bool>(false);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();