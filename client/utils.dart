U32BigToInt(List<int> data, int offset) {
  return ((data[offset] << 24) & 0xff000000) + 
         ((data[offset+1] << 16) & 0xff0000) +
         ((data[offset+2] << 8) & 0xff00) + 
         (data[offset+3] & 0xff);
}

U32ToInt(List<int> data, int offset) {
  return data[offset] & 0xff + 
         ((data[offset+1] << 8) & 0xff00) + 
         ((data[offset + 2] << 16) & 0xff0000) + 
         ((data[offset + 3] << 24) & 0xff000000);
}
U16BigToInt(List<int> data, int offset) {
  return ((data[offset] << 8) & 0xff00) + (data[offset+1] & 0xff);
}

U16ToBigEndian(int data) {
  return [(data>>8) & 0xff, data & 0xff];
}

ConvertU16(int data, List<int> array, int offset) {
  var bigs = U16ToBigEndian(data);
  array[offset] = bigs[0];
  array[offset + 1] = bigs[1];
}

U32ToBigEndian(int data) {
  return [(data>>24) & 0xff, (data>>16) & 0xff, (data>>8) & 0xff, (data & 0xff)];
}

ConvertU32(int data, List<int> array, int offset) {
  var bigs = U32ToBigEndian(data);
  array[offset] = bigs[0];
  array[offset + 1] = bigs[1];
  array[offset + 2] = bigs[2];
  array[offset + 3] = bigs[3];
}


class utils {
  
}
