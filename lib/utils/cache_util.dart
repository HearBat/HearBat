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
      totalSize += await entity.length();
    }
  }
  return totalSize;
}

// Clears the entire cache
Future<void> clearCache() async {
  final dirPath = (await getTemporaryDirectory()).path;
  final dir = Directory(dirPath);
  final files = dir.listSync();

  for (final file in files) {
    if (file is File) {
      await file.delete();
    }
  }
}

// Delete cached file by associated word
Future<void> clearCacheWord(String word) async {
  final dirPath = (await getTemporaryDirectory()).path;
  final dir = Directory(dirPath);
  final dirList = dir.listSync(followLinks: false);

  // Search for matching file
  for (FileSystemEntity file in dirList) {
    final filename = file.path.split('/').last;
    if (filename.startsWith("${word}_")) {
      await file.delete();
      break;
    }
  }
}
