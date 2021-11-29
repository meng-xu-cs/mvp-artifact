# Artifact for Paper Fast and Reliable Formal Verification of Smart Contracts with the Move Prover

- Paper submission number: 99
- Artifaction submission number: 100

## Evaluation Setup

The evaluation happens on the virtual machine image provided by TACAS 22. The virtual machine is configured to have 1 CPU core and 8 GB memory. The VM is emulated by VMware Workstation 16 Player. The host machine runs on Ubuntu 20.04 LTS with 11th Gen Intel(R) Core(TM) i7-11800H (8 cores) and 64 GB memory. Internet connection is not required for the artifact evaluation.

## TL;DR

For a quick instruction on reproducing the results in the paper:

```shell script
cd <path-to-where-this-artifact-is-unzipped>

# verification of Diem Framework with current version of MVP
./verify-diem-v2

# performance comparison between a prior and the current version of MVP
./verify-diem-v1 perf data/diem-v1/LibraAccount.move
./verify-diem-v2 perf data/diem-v2/DiemAccount.move

# case study on a timeout that happens in the prior version of MVP
./mvp-v1 data/diem-v1/LibraSystem.move -d data/diem-v1/ --timeout 100
./mvp-v2 data/diem-v2/DiemSystem.move -d data/diem-v2/
```

The rest of the README contains a more thorough description on the commands above as well as an in-depth introduction to the MVP, which can be read selectively.

## Directory Layout

```text
artifact/
│
├── bin/                # pre-built static binaries for the Move Prover (MVP)
│    ├─ move-prover-v1  # the prior release of MVP (September 2020)
│    └─ move-prover-v2  # the latest release of MVP (October 2021)
│
├── dep/                # dependencies of MVP
│    ├─ hyperfine       # a utility tool that calculates statistics on program execution time
│    ├─ z3              # the Z3 solver executable (version 4.8.9)
│    ├─ cvc4            # the CVC4 solver executable (version 1.9-prerelease)
│    └─ dotnet/         # the .NET framework distribution (version 5.0.208)
│       ├─ ...          # standard .NET framework library files
│       └─ tools/boogie # the Boogie executable (version 3.9.0.0)
│
├── data/               # Move code samples for evaluation
│   ├─ diem-v1          # the Diem framework code used to evaluate the prior release of MVP
│   ├─ diem-v2          # the Diem framework code used to evaluate the latest release of MVP
│   ├─ examples         # examples used to evaluate and demonstrate the core features of MVP
│   └─ tutorial         # Move programs used in the generic tutorial for MVP
│
├── doc/
│   ├─ move-lang        # documentation about the Move programming language
│   └─ spec-lang        # documentation about the Move specification language
│
├── mvp-v1              # a Bash wrapper to bin/move-prover-v1 with environment setup
├── mvp-v2              # a Bash wrapper to bin/move-prover-v2 with environment setup
├── mvp                 # a symbolic link to the most recent release of MVP (i.e., mvp-v2)
│
├── verify-diem-v1      # an utility driver for verifying Move files in data/diem-v1
├── verify-diem-v2      # an utility driver for verifying Move files in data/diem-v2
│
├── License.txt         # the License under which this artifact is published
└── Readme.txt          # this file
```

## Move Prover (MVP) Introduction

The Move Prover (MVP) supports formal specification and verification of Move code. It can automatically prove logical properties of Move smart contracts, while providing a user experience similar to a type checker or linter. It's purpose is to make contracts more *trustworthy*, specifically:

- Protect massive assets managed by the Diem blockchain from smart contract bugs
- Protect against well-resourced adversaries
- Anticipate justified regulator scrutiny and compliance requirements
- Allow domain experts with mathematical background, but not necessarily software engineering background, to
  understand what smart contracts do

## Installation

MVP is released as 64-bit pre-built static executables compatible with at least Ubuntu 20.04 LTS for artifact evaluation. They are expected to be working out-of-the-box, as long as all dependencies (Z3, CVC4, and Boogie) are provided.

To run MVP for artifact evaluation, we recommend using the bash wrappers `mvp-v1` and `mvp-v2` to invoke the prior release of MVP and the current release of MVP, respectively. The `mvp` file is a symbolic link to `mvp-v2`. We highly recommend the users to set an alias of `mvp` by
```shell script
alias mvp=<path-to-where-this-artifact-is-unzipped>/mvp
```

Unless stated otherwise, the following commands are applicable to the latest version of MVP (i.e., `mvp-v2`) in this artifact.

## Evaluations on The Performance of MVP

### Verification of The Whole Diem Framework

The current Diem Framework release can be verified by MVP with the following command:

```shell script
./verify-diem-v2
```

This will iterate over each of the source code files in the Diem Framework and run modular verification on a per-file basis.

The Diem Framework code can also be verified as a whole package via the following command:

```shell script
./verify-diem-v2 data/diem-v2/
```

The verification is expected to finish in about 1 minute, which is slightly faster than verifying all files sequentially. This is because MVP takes a modular verification approach and when verifying a Move file `M`, it will build a cluster of files that are related to `M` and send the whole cluster for verification instead of just the content in `M`. More details on modular verification can be found in the paper.

### Case Study on LibraAccount / DiemAccount

The numbers in Section 4 - Analysis of the paper (page 14) can be reproduced with the following commands:

```shell scrpit
./verify-diem-v1 perf data/diem-v1/LibraAccount.move
./verify-diem-v2 perf data/diem-v2/DiemAccount.move
```

The first command profiles the performance on the `LibraAccount` from V1 Diem Framework using the V1 version of MVP, while the second command profiles the performance on the `DiemAccount` from V2 Diem Framework.

Using the setup above, the output is

- `LibraAccount` (using MVP V1, the prior version of MVP)
  ```text
  Time (mean ± σ):     11.607 s ±  0.267 s    [User: 9.899 s, System: 0.254 s]
  Range (min … max):   10.870 s … 11.785 s    10 runs
  ```

- `DiemAccount` (using MVP V2, the current version of MVP)
  ```text
  Time (mean ± σ):      8.468 s ±  0.027 s    [User: 7.340 s, System: 0.254 s]
  Range (min … max):    8.429 s …  8.508 s    10 runs
  ```

NOTE: the numbers differ slightly from the numbers in the paper due to the fact that the computation happens on a virtual machine instead of natively. But the reduction of verification time and a smaller standard deviation stays the same.

It is also worthnoting that performance evaluation of the `DiemAccount` has cluster verification turned off to make a fair comparison between the two versions of MVP. In particular, in this case, the file cluster is built and all global invariants defined in other modules will be incorporated in the verification of `DiemAccount`. But only code written in `DiemAccount` will be sent for verification while code in other modules are filtered out. This is on par with what happens in MVP V1 and makes the comparison fair.

To see the performance of `DiemAccount` without the filtering in MVP V2, simply run, and notice the increase of total verification time.
```shell script
./verify-diem-v2 data/diem-v2/DiemAccount.move
```

### Case Study on Timeouts And Butterfly Effects

The `LibraSystem::update_config_and_reconfigure` from the V1 version of Diem Framework takes extremely long time to verify in MVP V1 (if it can be verified). Most of the time the verification fails with timeout, which can be experienced with the command below:

```shell script
./mvp-v1 data/diem-v1/LibraSystem.move -d data/diem-v1/ --timeout 100
```

With all the improvements in the V2 version of MVP, the timeout has gone and the whole module can be verified within a few seconds, as can be demonstrated with the following command:

```shell script
./mvp-v2 data/diem-v2/DiemSystem.move -d data/diem-v2/
```

## Demonstrations of Key Components in MVP

MVP is a substantial and evolving piece of software that has been tuned and optimized in many ways. As a result, it is not easy to define exactly what implementation decisions lead to fast and reliable performance. However, we can at least identify three major ideas that resulted in dramatic improvements in speed and reliability since the description of an early prototype of MVP (a.k.a, `mvp-v1` in this artifact package). Aligned with the paper, the evaluation focuses on the three identified core ideas:

### Reference Elimination

Examples in this section is to show how the borrow semantics in Move allow the elimination of references from a Move program.

#### Immutable References

We show how immutable references can be eliminated in the following Move code, which is available under `data/examples/imm_ref/test.move`:

```move
module 0x1::Test {
  struct R { x: u64 }

  fun test(r_ref: &R): u64 {
    let x_ref = & r_ref.x;
    *x_ref
  }
}
```

We run MVP and intercept the intermediate results in the transformation pipeline:

```shell script
cd data/examples/imm_ref
mvp test.move --dump-bytecode
diff -u test.move_1_debug_instrumenter.bytecode test.move_2_eliminate_imm_refs.bytecode
cd -
```

The `diff` output should be the following and pay attention to the places where the immutable reference to `struct R` is eliminated, including
- the type of function argument `r_ref`
- the type of variable `$t2`
- the type of variable `$t1`
- the change of instruction from `borrow_field` to `get_field` (for variable `$t3`)
- the change of instruction from `read_ref` to `move` (for variable `$t4`)

```diff
--- test.move_1_debug_instrumenter.bytecode	2021-11-01 03:26:46.565939776 +0100
+++ test.move_2_eliminate_imm_refs.bytecode	2021-11-01 03:26:46.565939776 +0100
@@ -1,19 +1,19 @@
-============ after processor `debug_instrumenter` ================
+============ after processor `eliminate_imm_refs` ================
 
 [variant baseline]
-fun Test::test($t0|r_ref: &Test::R): u64 {
-     var $t1|x_ref: &u64
-     var $t2: &Test::R
-     var $t3: &u64
-     var $t4: &u64
+fun Test::test($t0|r_ref: Test::R): u64 {
+     var $t1|x_ref: u64
+     var $t2: Test::R
+     var $t3: u64
+     var $t4: u64
      var $t5: u64
   0: trace_local[r_ref]($t0)
   1: $t2 := move($t0)
-  2: $t3 := borrow_field<Test::R>.x($t2)
+  2: $t3 := get_field<Test::R>.x($t2)
   3: $t1 := $t3
   4: trace_local[x_ref]($t1)
   5: $t4 := move($t1)
-  6: $t5 := read_ref($t4)
+  6: $t5 := move($t4)
   7: trace_return[0]($t5)
   8: return $t5
 }
```

#### Mutable References

We show how MVP can handle mutable references derived from multiple roots of borrows without the need of explicit alias analysis.

This can be demonstrated in test case `data/examples/mut_ref/test.move`, which has the following content:

```move
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
```

We run MVP and intercept the intermediate results in the transformation pipeline:

```shell script
cd data/examples/mut_ref
mvp test.move --dump-bytecode
cat test.move_8_clean_and_optimize.bytecode
cd -
```

Pay attention to where the `is_parent` checks are instrumented in the code:
```diff
============ after processor `clean_and_optimize` ================

[variant baseline]
fun Test::caller($t0|p: bool): (Test::X, Test::Y) {
     var $t1|r: &mut u64
     var $t2|x: Test::X
     var $t3|y: Test::Y
     var $t4: u64
     var $t5: u64
     var $t6: &mut Test::X
     var $t7: &mut Test::Y
     var $t8: &mut u64
     var $t9: u64
     var $t10: Test::X
     var $t11: Test::Y
     var $t12: bool
     var $t13: bool
  0: trace_local[p]($t0)
  1: $t4 := 0
  2: $t2 := pack Test::X($t4)
  3: trace_local[x]($t2)
  4: $t5 := 1
  5: $t3 := pack Test::Y($t5)
  6: trace_local[y]($t3)
  7: $t6 := borrow_local($t2)
  8: $t7 := borrow_local($t3)
  9: $t8 := Test::get_ref($t0, $t6, $t7)
 10: trace_local[r]($t8)
 11: $t9 := 5
 12: write_ref($t8, $t9)
 13: $t12 := is_parent[Reference($t6).a (u64)]($t8)
+    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+    implicit alias checking on whether $t8 points to $t6.a
 14: if ($t12) goto 15 else goto 17
 15: label L1
 16: write_back[Reference($t6).a (u64)]($t8)
 17: label L2
 18: $t13 := is_parent[Reference($t7).b (u64)]($t8)
+    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+    implicit alias checking on whether $t8 points to $7.b
 19: if ($t13) goto 20 else goto 22
 20: label L3
 21: write_back[Reference($t7).b (u64)]($t8)
 22: label L4
 23: write_back[LocalRoot($t2)@]($t6)
 24: write_back[LocalRoot($t3)@]($t7)
 25: $t10 := move($t2)
 26: $t11 := move($t3)
 27: trace_return[0]($t10)
 28: trace_return[1]($t11)
 29: return ($t10, $t11)
}


[variant baseline]
fun Test::get_ref($t0|p: bool, $t1|x: &mut Test::X, $t2|y: &mut Test::Y): &mut u64 {
     var $t3|tmp#$3: &mut u64
     var $t4: &mut u64
     var $t5: &mut u64
     var $t6: bool
     var $t7: bool
  0: trace_local[p]($t0)
  1: trace_local[x]($t1)
  2: trace_local[y]($t2)
  3: if ($t0) goto 6 else goto 4
  4: label L1
  5: goto 12
  6: label L0
  7: destroy($t2)
  8: $t4 := borrow_field<Test::X>.a($t1)
  9: $t3 := $t4
 10: trace_local[tmp#$3]($t4)
 11: goto 17
 12: label L2
 13: destroy($t1)
 14: $t5 := borrow_field<Test::Y>.b($t2)
 15: $t3 := $t5
 16: trace_local[tmp#$3]($t5)
 17: label L3
 18: trace_return[0]($t3)
 19: trace_local[x]($t1)
 20: trace_local[y]($t2)
 21: label L4
 22: label L5
 23: label L6
 24: label L7
 25: return $t3
}
```

This feature is not supported in the V1 version of MVP. `test_for_v1.move` shows the the same test case adapted to the syntax of Move and MVP in the V1 version. Running `mvp-v1 test_for_v1.move` yields the following error:
```text
bug: output.bpl(1562,4): Error: call to undeclared procedure: $Splice2

      ┌── output.bpl:1562:5 ───
      │
 1562 │     call $t11 := $Splice2(1, $t7, 2, $t8, $t11);
      │     ^
      │

bug: output.bpl(1710,4): Error: call to undeclared procedure: $Splice2

      ┌── output.bpl:1710:5 ───
      │
 1710 │     call $t11 := $Splice2(1, $t7, 2, $t8, $t11);
      │     ^
      │

Error: exiting with boogie verification errors
```

The way to avoid this issue in MVP V1 was to avoid writing mutable borrows that may originate from multiple roots, which is less optimal and does not match with the expresivenss of the Move language.

### Global Invariant Injection

Examples in this section demonstrates how the fine-grained global invariant injection looks like in the current version of MVP. In particular, the current version of MVP is capable of ensuring that invariants hold after *every instruction* in the code (unless explicitly directed to defer the invariant check the users). This is in contrast with the old approach where the granularity is *per public function*, i.e., all global invariants are instrumented as 1) a `requires` in the pre-state of every public function and 2) an `ensures` in the post-state of every public function.

#### Translation of Non-generic Invariants

We show how a simple invariant instrumentation case works in MVP. The example is available under `data/examples/inv_concrete/test.move`.

```move
module 0x1::Test {
    struct R has key { v: u64 }

    spec module {
        invariant [global] forall a: address: global<R>(a).v > 0;
    }

    public fun publish(s: &signer) {
        move_to<R>(s, R{v:1});
    }
}
```

We run MVP and intercept the intermediate results in the transformation pipeline:

```shell script
cd data/examples/inv_concrete
mvp test.move --dump-bytecode
cat test.move_14_global_invariant_instrumentation.bytecode
cd -
```

Pay attention to where the global invariant is instrumented to the code:

```diff
invariant_instrumentation.bytecode 
============ after processor `global_invariant_instrumentation` ================

[variant verification]
public fun Test::publish($t0|s: signer) {
     var $t1: u64
     var $t2: Test::R
     var $t3: num
     # global invariant at test.move:5:9+57
  0: assume forall a: TypeDomain<address>(): Gt(select Test::R.v(global<Test::R>(a)), 0)
+ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+ Assuming the invariant at the starting of the function establishes the basis of the induction proof for this invariant
  1: trace_local[s]($t0)
  2: $t1 := 1
  3: $t2 := pack Test::R($t1)
  4: move_to<Test::R>($t2, $t0) on_abort goto 8 with $t3
     # global invariant at test.move:5:9+57
     # VC: global memory invariant does not hold at test.move:5:9+57
  5: assert forall a: TypeDomain<address>(): Gt(select Test::R.v(global<Test::R>(a)), 0)
+ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+ Asserting the invariant right after the instruction that might cause the invariant to violate. This assertion re-establishes the invariant for the rest of the code.
  6: label L1
  7: return ()
  8: label L2
  9: abort($t3)
}
```

#### Translation of Generic Invariants

Generic type parameters make the problem of determining whether a function can modify an invariant more difficult, which is recognized and handled by the current version of MVP. An example to illustrate how MVP handles invariants in a generic context is in `examples/inv_generic/test.move`:

```move
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
```

To see how MVP handles the instrumentation of a generic invariant into a concrete function, run the following command and observe the intermediate result:

```shell script
cd examples/inv_generic
mvp test.move --dump-bytecode
cat test.move_14_global_invariant_instrumentation.bytecode
cd -
```

Pay attention not only to where this invariant is instrumented in the code, but also the instantiation of type parameter `T` with `bool`:

```diff
============ after processor `global_invariant_instrumentation` ================

[variant verification]
public fun Test::test($t0|account: signer) {
     var $t1: bool
     var $t2: u64
     var $t3: Test::R<bool>
     var $t4: num
     # global invariant at test.move:9:5+80
  0: assume forall a: TypeDomain<address>(): Implies(exists<Test::R<bool>>(a), Gt(select Test::R.v(global<Test::R<bool>>(a)), 0))
+                                                                   ^^^^                                          ^^^^           
+ Notice how the invariant is instrumented with instantiation to its type parameters
  1: trace_local[account]($t0)
  2: $t1 := false
  3: $t2 := 1
  4: $t3 := pack Test::R<bool>($t1, $t2)
  5: move_to<Test::R<bool>>($t3, $t0) on_abort goto 9 with $t4
     # global invariant at test.move:9:5+80
     # VC: global memory invariant does not hold at test.move:9:5+80
  6: assert forall a: TypeDomain<address>(): Implies(exists<Test::R<bool>>(a), Gt(select Test::R.v(global<Test::R<bool>>(a)), 0))
+                                                                   ^^^^                                          ^^^^           
+ Notice how the invariant is instrumented with instantiation to its type parameters
  7: label L1
  8: return ()
  9: label L2
 10: abort($t4)
}
```

#### Global Update Invariants

While a global invariant places a restriction on any *single* state of the global storage, a global update invariant restricts whether a change from one global state to another can be allowed. This feature is illustrated in `examples/inv_update/test.move`:

```move
module 0x1::Test {
  struct R has key { x: u64 }

  spec module {
    invariant update [global] forall a: address:
      old(exists<R>(a)) ==> exists<R>(a);
  }

  public fun incr(a: address) acquires R {
    let r = borrow_global_mut<R>(a);
    r.x = r.x + 1;
  }
}
```

To see the effect of this update invariant, run the MVP and intercept its intermediate results:

```shell script
cd examples/inv_update
mvp test.move --dump-bytecode
cat test.move_14_global_invariant_instrumentation.bytecode
cd -
```

Notice that for global update invariants, there is no assumption of the invariant. Instead, there is a "snapshot" function which takes a snapshot of the global memory at the given state and allows the state to be referred later by name:

```diff
============ after processor `global_invariant_instrumentation` ================

[variant verification]
public fun Test::incr($t0|a: address) {
     var $t1|r: &mut Test::R
     var $t2: &mut Test::R
     var $t3: num
     var $t4: u64
     var $t5: u64
     var $t6: u64
     var $t7: &mut u64
  0: trace_local[a]($t0)
  1: $t2 := borrow_global<Test::R>($t0) on_abort goto 14 with $t3
  2: trace_local[r]($t2)
  3: $t4 := get_field<Test::R>.x($t2)
  4: $t5 := 1
  5: $t6 := +($t4, $t5) on_abort goto 14 with $t3
  6: $t7 := borrow_field<Test::R>.x($t2)
  7: write_ref($t7, $t6)
  8: write_back[Reference($t2).x (u64)]($t7)
     # state save for global update invariants
  9: @1 := save_mem(Test::R)
+ ^^^^^^^^^^^^^^^^^^^^^^^^^^
+ Snapshoting the state and name the snapshot @1
 10: write_back[Test::R@]($t2)
     # global invariant at test.move:5:5+86
     # VC: global memory invariant does not hold at test.move:5:5+86
 11: assert forall a: TypeDomain<address>(): Implies(exists[@1]<Test::R>(a), exists<Test::R>(a))
+                                                           ^^                                 
+ Notice how the state snapshot is referred in the checking of state transitions
 12: label L1
 13: return ()
 14: label L2
 15: abort($t3)
}
```

Note that this feature is not supported in the V1 version of MVP as the state transition is usually expressed at the instruction granularity instead of the function boundaries.

### Monomorphization

Monomorphization is a transformation which removes generic types from a Move program by *specializing* the program for relevant type instantiations. Such specialization might be caused by either the Move code having type-dependent behaviors or the instrumented global invariant requires a specialized type parameter to evaluate. An example is presented in `data/examples/mono/test.move` and also shown in the following:

```move
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
```

To see how MVP specializes the `test` function, run MVP over the Move file and intercept the intermediate result

```shell script
cd data/examples/mono
mvp test.move --keep  # notice: --keep forces MVP to save the generated Boogie file in the directory 
cat output.bpl
cd -
```

Notice how the `0x1::Test::test` function are handled in the generated Boogie program. In particular, notice that the function now generates three verification targets now:

```diff
type #0;

// fun Test::test [verification] at test.move:4:3+91
procedure {:timeLimit 40} $1_Test_test$verify(_$t0: $signer, _$t1: #0) returns () { .. }
+                                                                  ^^
+ The generic type parameter `T` is skolemized to a concrete but uninterpreted type `#0`. 

// fun Test::test<bool> [verification] at test.move:4:3+91
+                 ^^^^
procedure {:timeLimit 40} $1_Test_test'bool'$verify(_$t0: $signer, _$t1: bool) returns () { .. }
+                                      ^^^^                              ^^^^
+ The function is specialized in order to check the global invariant about `R<bool>`

// fun Test::test<u64> [verification] at test.move:4:3+91
+                 ^^^
procedure {:timeLimit 40} $1_Test_test'u64'$verify(_$t0: $signer, _$t1: int) returns () { .. }
+                                      ^^^                              ^^^
+ The function is specialized in order to check the global invariant about `R<u64>`
```

## A General Tutorial on MVP

### Command Line Interface

MVP has a traditional compiler-style command line interface: you pass a set of sources, tell it where to look for dependencies of those sources, and optionally provide flags to control operation:

```shell script
> mvp --dependency data/tutorial/case1 data/tutorial/case1/N.move
> # Short form:
> mvp -d data/tutorial/case1 data/tutorial/case1/N.move 
```

Above, we process the `N.move` file in the `data/tutorial/case1/` directory, and tell the prover to look up any dependencies this source might have in that directory. The verification should succeed, the prover should terminate with printing
some statistics dependent on the configured verbosity level. In this case, the output should be similar to (NOTE: timing might be different):

```text
[INFO] translating module N
[INFO] running solver
[INFO] 0.001s build, 0.000s trafo, 0.002s gen, 0.579s verify
[INFO] Total prover time in ms: 581
```

In case MVP fails, it will print diagnosis, as will be discussed below.
Run `mvp --help` for a complete list of options supported by MVP and advanced settings.

### Diagnosis 

When MVP finds a verification error, it prints out diagnosis in a style similar to a compiler or a debugger. We explain the different types of diagnoses below, based on the following evolving example:

```move
// cat data/tutorial/case2/M_correct.move

address 0x1 {
module M {
  struct Counter has key, store {
    value : u8,
  }  

  public fun increment(a: address) acquires Counter {
    let r = borrow_global_mut<Counter>(a);
    r.value = r.value + 1;
  }
  spec increment {
    aborts_if !exists<Counter>(a);
    ensures global<Counter>(a).value == old(global<Counter>(a)).value + 1;
  }
}
}
```

#### Unexpected Abort

If we run MVP with the above Move code:

```shell script
mvp data/tutorial/case2/M_missing_abort.move
```

We get the following error:
```
error: abort not covered by any of the `aborts_if` clauses
   ┌─ M_missing_abort.move:11:3
   │  
 9 │       r.value = r.value + 1;
   │                         - abort happened here with execution failure
10 │     }
11 │ ╭   spec increment {
12 │ │     aborts_if !exists<Counter>(a);
13 │ │     ensures global<Counter>(a).value == old(global<Counter>(a)).value + 1;
14 │ │   }
   │ ╰───^
   │  
   =     at M_missing_abort.move:7: increment
   =         a = 0x29
   =     at M_missing_abort.move:8: increment
   =         r = &M.Counter{value = 255u8}
   =     at M_missing_abort.move:9: increment
   =     at M_missing_abort.move:9: increment
   =         ABORTED

exiting with boogie verification errors
```

The prover has generated a counter example which leads to an overflow when adding 1 the value of 255 for an `u8`. This happens if the function specification states something abort abort behavior, but the condition under which the function is aborting is not covered by the specification. And in fact, with `aborts_if !exists<Counter>(a)` we only cover the abort if the resource does not exists, but not the overflow.

Let's fix the above and add the following condition:

```move
  aborts_if global<Counter>(a).value == 255;
```
to the specification of the `increment` function (see the `M_correct.move` file).

With this, the prover will succeed without any errors:
```shell script
mvp data/tutorial/case2/M_correct.move
```

```text
[INFO] translating module M
[INFO] running solver
[INFO] 0.001s build, 0.001s trafo, 0.002s gen, 0.754s verify
[INFO] Total prover time in ms: 756
```

#### Post-conditions might not hold

Let us inject an error into the `ensures` condition of the above example:
```move
  ensures global<Counter>(a).value == old(global<Counter>(a)).value + 2;
```
This change is shown in the `M_bad_ensures.move` file.

With this, MVP will produce the following diagnosis:
```text
error: post-condition does not hold
   ┌─ M_bad_ensures.move:15:5
   │
15 │     ensures global<Counter>(a).value == old(global<Counter>(a)).value + 2;
   │     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   │
   =     at M_bad_ensures.move:7: increment
   =         a = 0x18be
   =     at M_bad_ensures.move:8: increment
   =         r = &M.Counter{value = 107u8}
   =     at M_bad_ensures.move:9: increment
   =     at M_bad_ensures.move:10: increment
   =     at M_bad_ensures.move:12
   =     at M_bad_ensures.move:13
   =     at M_bad_ensures.move:15

exiting with boogie verification errors
```

## Availability of Artifact 

### Pre-built Binaries for MVP

Pre-built binaries of MVP, together with this README file and all related Move code, is available on GitHub with
this [link](https://github.com/mengxu-fb/mvp-artifact).

### Building MVP from Scratch

MVP binaries can be built from source code too in an environment with network connections, with the following steps:

```bash
# clone the Diem repository
git clone https://github.com/diem/diem.git
cd diem

# setup the compilation toolchain 
git checkout release-1.5
./scripts/dev_setup.sh -yp

# move to the move-prover crate
cd language/move-prover

# to build the V2 MVP executable 
git checkout release-1.5
RUSTFLAGS='-C target-feature=+crt-static' cargo build --release
# --> the binary can be found under diem/target/release/move-prover

# to build the V1 MVP executable
git checkout release-1.0 
RUSTFLAGS='-C target-feature=+crt-static' cargo build --release
# --> the binary can be found under diem/target/release/move-prover
```

