# Ruffle + libTAS Flash RNG / AVM1 replication handoff

## Versions used

```text
Ruffle:
0.2.0-nightly.2026.5.15-nightly
commit 69afbe077a11dcdf44af307a85eedbe4bc314352

libTAS:
1.4.7

libTAS time tracking:
clock_gettime() monotonic
```

When reproducing behavior, **use source code from exactly those versions**. Current Ruffle/libTAS may differ.

---

## 1. Ruffle AVM RNG: exact behavior

For AVM1 Flash `random(n)` / `ActionRandomNumber`, Ruffle uses `AvmRng`.

Ruffle source at this exact commit:

```text
core/src/avm_rng.rs
```

The RNG state is:

```rust
u_value: u32
```

It is initialized **lazily on first RNG use**, not at emulator startup:

```text
if u_value == 0:
    seed = current_datetime.timestamp_micros() as u32
    u_value = seed
```

Thus the seed is:

```text
(uint32_t) Unix CLOCK_REALTIME in microseconds
```

at the instant the first Flash RNG call occurs. 

The core transition is:

```text
if state & 1:
    state = (state >> 1) XOR 0x48000000
else:
    state >>= 1

a = (int32) state
a = wrapping_i32(a * 71)
a = pure_hasher(a)
result = a & 0x7fffffff
```

The hasher constants are:

```text
C1 = 1376312589
C2 = 789221
C3 = 15731
```

and:

```text
pure_hasher(x):

x = ((x << 13) XOR x) - (x >> 21)     // wrapping i32

r = x*x                                  // wrapping
r = r*15731                              // wrapping
r = r+789221                             // wrapping
r = r*x                                  // wrapping
r = r+1376312589                         // wrapping
r &= 0x7fffffff

r = r+x                                  // wrapping
r = ((r << 13) XOR r) - (r >> 21)       // wrapping

return r
```

All relevant arithmetic is **32-bit wrapping signed arithmetic**. 

### AVM1 `random(max)`

Ruffle's AVM1 `RandomNumber` opcode does:

```text
max = pop stack, coerced to i32

if max > 0:
    result = generate_random_number() % max
else:
    result = 0
```

It does **not** generate a float and multiply by `max`. 

---

## 2. Standalone C implementation of the Ruffle RNG

For Linux/GCC/Clang:

```c
#include <stdint.h>

typedef struct {
    uint32_t state;
} AvmRng;

#define AVM_C1 ((int32_t)1376312589)
#define AVM_C2 ((int32_t)789221)
#define AVM_C3 ((int32_t)15731)

static inline int32_t wrap_add_i32(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a + (uint32_t)b);
}

static inline int32_t wrap_sub_i32(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a - (uint32_t)b);
}

static inline int32_t wrap_mul_i32(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a * (uint32_t)b);
}

static int32_t pure_hasher(int32_t x)
{
    /*
     * On Linux/GCC/Clang, signed >> is arithmetic, matching Rust i32 >>.
     * Left shifts are done as uint32_t to avoid C signed-shift UB.
     */
    int32_t y =
        (int32_t)(((uint32_t)x << 13) ^ (uint32_t)x);

    x = wrap_sub_i32(y, x >> 21);

    int32_t r = wrap_mul_i32(x, x);
    r = wrap_mul_i32(r, AVM_C3);
    r = wrap_add_i32(r, AVM_C2);
    r = wrap_mul_i32(r, x);
    r = wrap_add_i32(r, AVM_C1);

    r &= 0x7fffffff;

    r = wrap_add_i32(r, x);

    y = (int32_t)(((uint32_t)r << 13) ^ (uint32_t)r);
    r = wrap_sub_i32(y, r >> 21);

    return r;
}

static int32_t avm_rng_next(AvmRng *rng)
{
    if (rng->state & 1)
        rng->state = (rng->state >> 1) ^ 0x48000000U;
    else
        rng->state >>= 1;

    int32_t x = (int32_t)rng->state;

    x = wrap_mul_i32(x, 71);
    x = pure_hasher(x);

    return x & 0x7fffffff;
}

static int32_t avm_random(AvmRng *rng, int32_t max)
{
    if (max <= 0)
        return 0;

    return avm_rng_next(rng) % max;
}
```

To emulate a known Ruffle timestamp directly:

```c
AvmRng rng = {
    .state = ruffle_timestamp_us
};

int value = avm_random(&rng, 4);
```

**Special case:** internal state `0` means "not seeded yet" in Ruffle, so raw seed zero cannot simply be treated as an ordinary state if duplicating lazy initialization exactly. 

---

# 3. libTAS deterministic time

The relevant file in libTAS 1.4.7 is:

```text
src/library/DeterministicTimer.cpp
```

libTAS maintains:

```text
ticks              = deterministic monotonic clock
realtime_delta     = realtime - monotonic
CLOCK_REALTIME     = ticks + realtime_delta
```

During initialization:

```cpp
ticks = initial_monotonic_time;
realtime_delta = configured_initial_system_time - ticks;
```

So the user-facing **Starting system time** becomes the origin of deterministic realtime. 

---

## 4. Exact frame advancement

libTAS does not simply use an imprecise floating-point `1/fps`.

For each frame it computes an integer nanosecond base plus a fractional remainder.

Relevant code:

```text
baseTimeIncrement.tv_nsec =
    1,000,000,000 * (framerate_den % framerate_num)
    / framerate_num

fractional_increment =
    1,000,000,000 * (framerate_den % framerate_num)
    % framerate_num
```

and the fractional remainder occasionally adds another nanosecond. 

For a **24 FPS** SWF:

```text
frame 1: 41,666,666 ns
frame 2: 41,666,667 ns

total after two frames:
83,333,333 ns
```

For the grid game studied here, the first Flash RNG call occurs after those two frame advances.

Thus:

```text
Ruffle RNG time =
    libTAS Starting system time
    + 83,333,333 ns
```

for this specific game/startup sequence.

**Do not assume two frames for another SWF.** Determine when that game's first RNG call occurs.

---

# 5. Why arbitrary nanoseconds seemed confusing

Ruffle eventually does:

```text
timestamp_micros()
```

which discards sub-microsecond precision.

For this game:

```text
seed =
floor(
    (start_time_ns + 83,333,333)
    / 1000
) mod 2^32
```

Suppose:

```text
Starting system time = 4s, 0ns
```

Then:

```text
4,000,000,000
+  83,333,333
--------------
4,083,333,333 ns
```

Ruffle gets:

```text
4,083,333 µs
```

So:

```text
4s, 0ns -> seed 4083333
```

But because of the `+333 ns` remainder, the seed boundaries are shifted:

```text
start nsec 0..666
    -> seed ...83333

start nsec 667..1666
    -> seed ...83334

start nsec 1667..2666
    -> seed ...83335
```

etc.

---

# 6. Canonical way to represent every Ruffle seed in libTAS

There is no reason to use those awkward boundary values.

For target Ruffle seed `R`, choose:

```text
start_us = R - 83,333
```

and express `start_us` as libTAS seconds + nanoseconds:

```c
uint64_t start_us = target_seed - 83333ULL;

uint64_t start_sec  = start_us / 1000000ULL;
uint64_t start_nsec = (start_us % 1000000ULL) * 1000ULL;
```

That produces a `start_nsec` which is always a multiple of **1000 ns**.

Then:

```text
start_us * 1000
+ 83,333,333

= R*1000 + 333 ns
```

and Ruffle truncates that cleanly to:

```text
R µs
```

So **1 µs granularity is enough to reach every distinct Ruffle time seed**.

The relevant granularity is **1000 ns**, not `1/24 s`.

---

# 7. `clock_gettime() monotonic` time tracking

With libTAS time tracking enabled for monotonic calls, repeated tracked calls can force deterministic time forward.

libTAS counts the configured time-call type. Once its threshold is exceeded, it adds a **1 ms delay** to the deterministic timer. 

Specifically, the code effectively does:

```text
if tracked_call_count > threshold:
    addDelay(1 ms)
```

and `addDelay()` immediately increments `ticks`, while also recording the delay so the next frame increment compensates for it. 

Therefore for a **different Flash game** you must verify whether any such forced time advancement occurs before the first RNG call.

Do not blindly assume:

```text
first RNG time = start + N frames
```

until tested.

---

# 8. Recommended RNG validation procedure for another Flash game

Before implementing gameplay, validate only RNG generation.

1. Determine whether the SWF is AVM1 or AVM2.
2. Decompile/disassemble the SWF.
3. Find every RNG call:

   ```text
   RandomNumber
   Math.random
   ```
4. Determine which call is the first executed RNG call.
5. Determine how many RNG calls occur before the board/level state of interest.
6. Determine the SWF framerate.
7. Model libTAS deterministic time until the first RNG call.
8. Generate 16–64 observed random outcomes from Ruffle/libTAS.
9. Compare those to the C implementation.
10. Only proceed to game simulation after the RNG sequence matches.

A few dozen 4-way random values are an extremely strong fingerprint.

---

# 9. AVM1 execution order warning

This was crucial for the grid game and can matter in other Flash games.

Ruffle says AVM1 execution order is controlled by a global execution list based on instantiation order. 

New MovieClips are inserted with:

```text
new_clip.next = current_head
head = new_clip
```

so the execution list is effectively **reverse creation order**. 

For the grid game:

```text
cells created:
row 0 col 0
row 0 col 1
...
row 15 col 15
```

therefore the relevant per-frame execution direction was:

```text
row 15 col 15
...
row 0 col 0
```

Using ordinary row-major simulation produced large errors:

```text
predicted cascade: 3128
actual:             2325
```

Changing to reverse execution order produced:

```text
predicted: 2325
actual:    2325
```

This is a good warning for any AVM1 game:

> Never automatically model `onEnterFrame` behavior as a synchronous cellular automaton.

---

# 10. Game-specific facts for this particular grid game

These should **not** be carried over to another SWF:

```text
board size: 16 x 16
framerate: 24 FPS
board RNG: random(4)
first RNG: after 2 libTAS frame advances
cell animation speed: 10 degrees/frame
click/runFunction: target rotation += 90 degrees
score: increments on every runFunction call
```

The board initialization does:

```text
_rotation = random(4) * 90
rot = _rotation
```

For the manually used direction numbering:

```text
0 = NW
1 = NE
2 = SE
3 = SW
```

the raw RNG mapping was:

```text
random(4)=0 -> SE -> oracle 2
random(4)=1 -> SW -> oracle 3
random(4)=2 -> NW -> oracle 0
random(4)=3 -> NE -> oracle 1
```

or:

```c
static const int raw_to_oracle[4] = {2, 3, 0, 1};
```

---

# 11. Known regression tests for this project

Use these before trusting a rebuilt simulator.

### Initial time

```text
libTAS Starting system time:
1s, 0ns
```

expected raw Ruffle seed:

```text
1083333
```

because:

```text
1,000,000,000 ns
+ 83,333,333 ns
= 1,083,333,333 ns
-> 1,083,333 us
```

Similarly:

```text
2s,0ns -> 2083333
3s,0ns -> 3083333
4s,0ns -> 4083333
```

### Cascade regression

For:

```text
raw seed = 3076083333
click = index 152
      = row 9, col 8
```

the correct cascade score under Ruffle/libTAS is:

```text
2325
```

A simulator returning:

```text
3128
```

is almost certainly processing the AVM1 cells in the wrong execution order.

---

# 12. Minimal conceptual architecture for another bruteforcer

Keep the layers separate:

```text
[libTAS clock model]
        |
        v
[Ruffle timestamp seed]
        |
        v
[exact Ruffle AVM RNG]
        |
        v
[SWF-specific random call sequence]
        |
        v
[initial game state]
        |
        v
[AVM1 event/execution model]
        |
        v
[game rules]
        |
        v
[score/search]
```

Do **not** mix them together.

This makes debugging much easier:

```text
wrong board
    -> clock/RNG/random-call-order bug

correct board, wrong score
    -> Flash/game execution semantics bug

correct board + known scores
    -> search layer can be trusted
```

That separation was the key lesson from this reverse-engineering session.
