U32BigToInt(List<int> data, int offset) {
  return data[offset] << 24 + data[offset+1] << 16 +
      data[offset+2] << 8 + data[offset+3];
}
U16BigToInt(List<int> data, int offset) {
  return ((data[offset] << 8) & 0xff00) + (data[offset+1] & 0xff);
}

class utils {
  
}
