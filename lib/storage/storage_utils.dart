String getFileExtension(String filename) {
  final lastIndex = filename.lastIndexOf('.');
  if (lastIndex != -1) {
    final ext = filename.substring(lastIndex).toLowerCase();
    if (ext.length <= 4) return ext;
  }
  return '';
}
