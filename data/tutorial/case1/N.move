address 0x1 {
module N {
  use 0x1::M;

  fun test(a: address) {
    M::increment(a);
    M::increment(a);
  }
  spec test {
    ensures global<M::Counter>(a).value == old(global<M::Counter>(a)).value + 2;
  }
}
}
