module 0x1::Test {
  struct R { x: u64 }

  fun test(r_ref: &R): u64 {
    let x_ref = & r_ref.x;
    *x_ref
  }
}

