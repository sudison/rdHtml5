class KeySyms {
  static final int XK_0 = 0x30;
  static final int XK_1 = 0x31;
  static final int XK_2 = 0x32;
  static final int XK_3 = 0x33;
  static final int XK_4 = 0x34;
  static final int XK_5 = 0x35;
  static final int XK_6 = 0x36;
  static final int XK_7 = 0x37;
  static final int XK_8 = 0x38;
  static final int XK_9 = 0x39;
  static final int XK_a = 0x61;
  static final int XK_b = 0x62;
  static final int XK_c = 0x63;
  static final int XK_d = 0x64;
  static final int XK_e = 0x65;
  static final int XK_f = 0x66;
  static final int XK_g = 0x67;
  static final int XK_h = 0x68;
  static final int XK_i = 0x69;
  static final int XK_j = 0x6a;
  static final int XK_k = 0x6b;
  static final int XK_l = 0x6c;
  static final int XK_m = 0x6d;
  static final int XK_n = 0x6e;
  static final int XK_o = 0x6f;
  static final int XK_p = 0x70;
  static final int XK_q = 0x71;
  static final int XK_r = 0x72;
  static final int XK_s = 0x73;
  static final int XK_t = 0x74;
  static final int XK_u = 0x75;
  static final int XK_v = 0x76;
  static final int XK_w = 0x77;
  static final int XK_x = 0x78;
  static final int XK_y = 0x79;
  static final int XK_z = 0x7a;
  static final int XK_Up = 0xff52;
  static final int XK_Down = 0xff54;
  static final int XK_Return = 0xff0d;
  static final int XK_Tab = 0xff09;
}

class UsKeyBoardMap {
   var map;
   UsKeyBoardMap() {
     map = new Map<int, int>();
     map[9] = KeySyms.XK_Tab;
     map[13] = KeySyms.XK_Return;
     map[65] = KeySyms.XK_a;
     map[38] = KeySyms.XK_Up;
     map[40] = KeySyms.XK_Down;
   }
   
   getKeySyms(int keyCode) {
     return map[keyCode];
   }
}
