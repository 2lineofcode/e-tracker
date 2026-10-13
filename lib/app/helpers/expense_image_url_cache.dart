class ExpenseImageUrlCache {
  final _entries = <String, ({DateTime expires, Future<String> url})>{};
  String? _userId;
  int _generation = 0;

  Future<String> load(String userId, String path, Future<String> Function() createUrl) {
    if (_userId != userId) {
      clear();
      _userId = userId;
    }
    final now = DateTime.now();
    final cached = _entries.remove(path);
    if (cached != null && now.isBefore(cached.expires)) {
      _entries[path] = cached;
      return cached.url;
    }
    final generation = _generation;
    late final Future<String> url;
    url = Future<String>.sync(createUrl).then((value) {
      if (generation != _generation) throw StateError('Image session changed');
      return value;
    }).catchError((Object error, StackTrace stack) {
      if (identical(_entries[path]?.url, url)) _entries.remove(path);
      Error.throwWithStackTrace(error, stack);
    });
    // Renew before the five-minute signed URL expires.
    _entries[path] = (expires: now.add(const Duration(minutes: 4)), url: url);
    if (_entries.length > 32) _entries.remove(_entries.keys.first);
    return url;
  }

  void clear() {
    _entries.clear();
    _userId = null;
    _generation++;
  }
}
