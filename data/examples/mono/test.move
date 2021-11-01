module 0x1::Test {
  struct R<T: store> has key { t: T, v: u64 }

  public fun test<T: store>(account: &signer, t: T) {
    move_to(account, R { t, v: 1 })
  }

  spec module {
    invariant forall a: address:
      exists<R<u64>>(a) ==> global<R<u64>>(a).v > 0;

    invariant forall a: address:
      exists<R<bool>>(a) ==> global<R<bool>>(a).v >= 0;
  }
}
