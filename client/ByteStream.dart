class ByteStream {
  List<int> _data;
  int _size;
  int _index;
  
  ByteStream() {
    _index = 0;
    _size = 0;
    _data = new List<int>();
  }
  
  AddData(List<int> data) {
    if (_size == _index) {
      _data.clear();
      _size = 0;
      _index = 0;
    }
    _data.addAll(data);
    _size += data.length;
  }
  
  int get size() => _size;
  int get avail() => (_size - _index);
  
  Advance(int step) {
    if ((step + _index) <= size) {
      _index += step;
    }
  }
  
  Seek(int offset) {
    if (offset < size) {
      _index = offset;
    }
  }
  
  Tail() {
    _index = _size;
  }
  
  ReadByte() {
    if (_index < _size) {
      int byte = _data[_index] & 0xff;
      _index += 1;
      return byte;
    }
  }
  
  PeekReadByte(int offset) {
    if (offset < _size) {
      return _data[offset] & 0xff;
    }
  }
  
  PeekReadU16(int offset) {
    if ((offset + 1) < _size) {
      return U16BigToInt(_data[offset], _data[offset + 1]);
    }
  }
  
  PeekReadU32(int offset) {
    if ((offset + 3) < _size) {
      return U32BigToInt(_data[offset], _data[offset + 1],
        _data[offset + 2], _data[offset + 3]);
    }
  }
  
  ReadU16() {
    if ((_index + 1) < size) {
      var value = U16BigToInt(_data[_index], _data[_index + 1]);
      Advance(2);
      return value;
    }
  }
  
  Read16() {
    if ((_index + 1) < size) {
      var value = (_data[_index] & 0xff) + ((_data[_index + 1] << 8) & 0xff00);
      Advance(2);
      return value;
    }
  }
  
  Read32() {
    if ((_index + 3) < size) {
      var value = (_data[_index] & 0xff) + (((_data[_index + 1] & 0xff) << 8) & 0xff00) +
          ((((_data[_index + 2] & 0xff) << 16) & 0xff0000)) + 
          (((_data[_index + 3] & 0xff) << 24) & 0xff000000);
      Advance(4);
      return value;
    }
  }
  
  ReadU32() {
    if ((_index + 3) < size) {
      var value = U32BigToInt(_data[_index], _data[_index + 1],
        _data[_index + 2], _data[_index + 3]);
      Advance(4);
      return value;
    }
  }
}
