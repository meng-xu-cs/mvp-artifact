module 0x1::Test {
    struct X { a: u64 }
    struct Y { b: u64 }

    fun get_ref(p: bool, x: &mut X, y: &mut Y): &mut u64 {
        if (p) &mut x.a else &mut y.b
    }

    fun caller(p: bool): (X, Y) {
        let x = X {a: 0};
        let y = Y {b: 1};
        let r = get_ref(p, &mut x, &mut y);
        *r = 5;
        (x, y)
    }
    spec caller {
        ensures  p ==> result_1 == X{a: 5} && result_2 == Y{b: 1};
        ensures !p ==> result_1 == X{a: 0} && result_2 == Y{b: 5};
    }
}
