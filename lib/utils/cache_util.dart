import 'dart:io';

import 'package:path_provider/path_provider.dart';

// Returns the cache size in bytes
Future<int> getCacheSize() async {
  final dirPath = (await getTemporaryDirectory()).path;
  final dir = Directory(dirPath);
  final dirList = dir.listSync(recursive: true, followLinks: false);

  int totalSize = 0;
  for (FileSystemEntity entity in dirList) {
    if (entity is File) {
      totalSize += entity.lengthSync();
    }
  }
  return totalSize;
}

// Clears the entire cache
Future<void> clearCache() async {
  final dirPath = (await getTemporaryDirectory()).path;
  final dir = Directory(dirPath);

  dir.deleteSync(recursive: true);
}

// Delete cached file by associated word
Future<void> clearCacheWord(String word) async {
  final dirPath = (await getTemporaryDirectory()).path;
  final dir = Directory(dirPath);
  final dirList = dir.listSync(followLinks: false);

  // Search for matching file
  for (FileSystemEntity entity in dirList) {
    final filename = entity.path.split('/').last;
    if (filename.startsWith("${word}_")) {
      entity.deleteSync();
      break;
    }
  }
}
