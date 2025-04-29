import 'dart:async';

import 'package:flutter/cupertino.dart';

StreamController<double> rightShoulderController =
    StreamController<double>.broadcast();
StreamController<double> leftShoulderController =
    StreamController<double>.broadcast();
StreamController<double> hip1Controller = StreamController<double>.broadcast();
StreamController<double> hip2Controller = StreamController<double>.broadcast();
StreamController<double> hip3Controller = StreamController<double>.broadcast();
StreamController<double> hip4Controller = StreamController<double>.broadcast();
StreamController<double> rightAnkleController =
    StreamController<double>.broadcast();
StreamController<double> leftAnkleController =
    StreamController<double>.broadcast();

const Color primaryColor = Color(0xff1F1A30);
