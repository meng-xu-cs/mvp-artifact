module 0x1::Test {
  struct R<T: store> has key { t: T, v: u64 }

  public fun test(account: signer) {
    move_to(&account, R { t: false, v: 1 })
  }

  spec module {
    invariant<T> forall a: address:
      exists<R<T>>(a) ==> global<R<T>>(a).v > 0;
  }
}
