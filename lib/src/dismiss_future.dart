import 'package:flutter/material.dart';

import 'loading.dart';

class LoadingDismissFuture {
  final OverlayEntry entry;
  Duration animDuration;
  bool isRemove = false;
  GlobalKey<LoadingWidgetState> loadingKey;

  LoadingDismissFuture(this.entry, this.loadingKey, this.animDuration) {
    FutureManager.getInstance().futures.add(this);
  }

  void dismiss([bool now = false]) {
    if (isRemove) {
      return;
    }
    isRemove = true;
    if (now) {
      FutureManager.getInstance().futures.remove(this);
      entry.remove();
      return;
    }
    FutureManager.getInstance().futures.remove(this);
    loadingKey.currentState?.dismissAnim();
    // PATCHED: remove the entry immediately instead of after animDuration.
    // The delayed removal left this dialog alive while the next show()
    // inserted a new one carrying the provider's single
    // GlobalKey<LoadingWidgetState>, crashing with "Multiple widgets used
    // the same GlobalKey" whenever a show landed within the 300ms fade-out.
    entry.remove();
  }
}

class FutureManager {
  static FutureManager? _instance;

  FutureManager._();

  factory FutureManager.getInstance() {
    _instance ??= FutureManager._();
    return _instance!;
  }

  var futures = <LoadingDismissFuture>[];

  dismissAll([bool now = true]) {
    futures.toList().forEach((f) {
      f.dismiss(now);
    });
    futures.clear();
  }
}
