String toByteString(int? bytes) {
  if (bytes == null) {
    return '0';
  }
  if (bytes <= (1 << 10)) {
    return '${bytes}B';
  } else if (bytes <= (1 << 20)) {
    return '${(bytes >> 10).toStringAsFixed(2)}K';
  } else {
    return '${(bytes >> 20).toStringAsFixed(2)}M';
  }
}
