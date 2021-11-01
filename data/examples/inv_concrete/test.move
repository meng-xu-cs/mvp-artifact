module 0x1::Test {
    struct R has key { v: u64 }

    spec module {
        invariant [global] forall a: address: global<R>(a).v > 0;
    }

    public fun publish(s: &signer) {
        move_to<R>(s, R{v:1});
    }
}
