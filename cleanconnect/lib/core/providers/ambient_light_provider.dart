import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ambient_light/ambient_light.dart';

final ambientLightLuxProvider = StreamProvider.autoDispose<double?>((ref) async* {
  final supported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (!supported) {
    yield null;
    return;
  }

  final ambient = AmbientLight();
  const pollInterval = Duration(seconds: 2);

  while (true) {
    try {
      final lux = await ambient.currentAmbientLight();
      yield lux?.toDouble();
    } on MissingPluginException {
      yield null;
    } catch (_) {
      yield null;
    }

    await Future<void>.delayed(pollInterval);
  }
});
