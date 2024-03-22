// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:gamepads_platform_interface/api/gamepad_controller.dart';
import 'package:gamepads_platform_interface/api/gamepad_event.dart';
import 'package:gamepads_platform_interface/method_channel_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gamepad_detector.dart';


abstract class GamepadsPlatformInterface extends PlatformInterface {
  static final Object _token = Object();

  GamepadsPlatformInterface() : super(token: _token);

  /// The default instance of [GamepadsPlatformInterface] to use.
  ///
  /// Defaults to [MethodChannelGamepadsPlatformInterface].
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GamepadsPlatformInterface] when they register
  /// themselves.
  static GamepadsPlatformInterface instance =
      GamepadsWeb();

  Future<List<GamepadController>> listGamepads();

  Stream<GamepadEvent> get gamepadEventsStream;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

/// A web implementation of the GamepadsWebPlatform of the GamepadsWeb plugin.
class GamepadsWeb extends GamepadsPlatformInterface {
  /// Constructs a GamepadsWeb
  GamepadsWeb(){
    html.window.addEventListener('gamepadconnected', (event) {
        //gamepads = getGamepads();
      emitGamepadEvent(GamepadEvent(
        gamepadId: '0',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        type: KeyType.button,
        // Assuming 'key' and 'value' are not applicable for connect/disconnect events.
        key: 'hahaha', // Not applicable for connection events
        value: 0.0, // Not applicable for connection events
      ));
    });

    html.window.addEventListener('gamepaddisconnected', (event) {
        //gamepads = getGamepads();
    });
  }

  @override
  Future<List<GamepadController>> listGamepads() async {
    return getGamepads();
  }

  static void registerWith(Registrar registrar) {
    //no need for this.
    //GamepadsPlatformInterface.instance = GamepadsWeb();
  }

  Future<void> platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onGamepadEvent':
        emitGamepadEvent(GamepadEvent.parse(call.args));
        break;
    }
  }

  void emitGamepadEvent(GamepadEvent event) {
    _gamepadEventsStreamController.add(event);
  }

  final StreamController<GamepadEvent> _gamepadEventsStreamController =
      StreamController<GamepadEvent>.broadcast();

  @override
  Stream<GamepadEvent> get gamepadEventsStream =>
      _gamepadEventsStreamController.stream;

  @mustCallSuper
  Future<void> dispose() async {
    _gamepadEventsStreamController.close();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
