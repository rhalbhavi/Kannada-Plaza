abstract interface class BrowserRefreshListener {
  void dispose();
}

bool get isBrowser => false;

BrowserRefreshListener listenForRefreshShortcut(String key) {
  return _NoopBrowserRefreshListener();
}

bool consumeRefreshShortcut(String key) => false;

class _NoopBrowserRefreshListener implements BrowserRefreshListener {
  @override
  void dispose() {}
}
