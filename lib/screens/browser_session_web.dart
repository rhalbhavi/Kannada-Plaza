import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

export 'browser_session_stub.dart' show BrowserRefreshListener;

import 'browser_session_stub.dart';

class _WebBrowserRefreshListener implements BrowserRefreshListener {
  _WebBrowserRefreshListener(this._listener) {
    web.window.addEventListener('keydown', _listener);
  }

  final web.EventListener _listener;

  @override
  void dispose() {
    web.window.removeEventListener('keydown', _listener);
  }
}

bool get isBrowser => true;

BrowserRefreshListener listenForRefreshShortcut(String key) {
  final listener = ((web.Event event) {
    final keyboardEvent = event as web.KeyboardEvent;
    if ((keyboardEvent.ctrlKey || keyboardEvent.metaKey) &&
        keyboardEvent.key.toLowerCase() == 'r') {
      try {
        web.window.sessionStorage.setItem(key, 'true');
      } on Object catch (error) {
        debugPrint('Unable to mark browser refresh: $error');
      }
    }
  }).toJS;
  return _WebBrowserRefreshListener(listener);
}

bool consumeRefreshShortcut(String key) {
  try {
    final wasMarked = web.window.sessionStorage.getItem(key) == 'true';
    web.window.sessionStorage.removeItem(key);
    return wasMarked;
  } on Object catch (error) {
    debugPrint('Unable to read browser refresh state: $error');
    return false;
  }
}
