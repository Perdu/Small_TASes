// AI-generated

#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <inttypes.h>

#define N 16
#define CELLS (N*N)
#define RNG_MASK 0x48000000u
#define RNG_MAX  0x7fffffff
#define C1 1376312589
#define C2 789221
#define C3 15731

/* Ruffle 69afbe0 AVM RNG, matching core/src/avm_rng.rs. */
typedef struct { uint32_t u; } AvmRng;
static inline int32_t wrap_i32(uint32_t x) { return (int32_t)x; }
static int32_t rng_next(AvmRng *r) {
    if (r->u & 1u) r->u = (r->u >> 1) ^ RNG_MASK;
    else           r->u >>= 1;

    int32_t s = (int32_t)r->u;
    s = (int32_t)((uint32_t)s * 71u);
    s = (int32_t)((uint32_t)((s << 13) ^ s) - (uint32_t)(s >> 21));

    int32_t x = (int32_t)((uint32_t)s * (uint32_t)s);
    x = (int32_t)((uint32_t)x * (uint32_t)C3);
    x = (int32_t)((uint32_t)x + (uint32_t)C2);
    x = (int32_t)((uint32_t)x * (uint32_t)s);
    x = (int32_t)((uint32_t)x + (uint32_t)C1);
    x &= RNG_MAX;
    x = (int32_t)((uint32_t)x + (uint32_t)s);
    x = (int32_t)((uint32_t)((x << 13) ^ x) - (uint32_t)(x >> 21));
    return x & RNG_MAX;
}

/* ActionRandomNumber in this Ruffle version is generate_random_number() % max. */
static inline int rng_mod(AvmRng *r, int max) {
    return max > 0 ? rng_next(r) % max : 0;
}

/* Orientations are the game's four normalized rotations:
 *   0 = SE, 1 = SW, 2 = NW, 3 = NE
 * i.e. 0, +90, +180, -90 degrees.
 */
static inline int has_north(int o) { return o == 2 || o == 3; }
static inline int has_south(int o) { return o == 0 || o == 1; }
static inline int has_west (int o) { return o == 1 || o == 2; }
static inline int has_east (int o) { return o == 0 || o == 3; }

static inline int connects(int o, int dr, int dc) {
    if (dr == -1) return has_north(o);
    if (dr ==  1) return has_south(o);
    if (dc == -1) return has_west(o);
    if (dc ==  1) return has_east(o);
    return 0;
}

static void board_from_seed(uint32_t seed, uint8_t b[CELLS]) {
    AvmRng r = { seed };
    if (!seed) {
        fprintf(stderr, "seed 0 is not a valid direct Ruffle seed: u_value==0 causes reseeding from realtime.\n");
        exit(2);
    }
    for (int i = 0; i < CELLS; ++i)
        b[i] = (uint8_t)rng_mod(&r, 4);
}

static void print_board(const uint8_t b[CELLS]) {
    static const char *name[4] = {"SE","SW","NW","NE"};
    for (int r = 0; r < N; ++r) {
        printf("Row %d:", r);
        for (int c = 0; c < N; ++c) printf(" %s", name[b[r*N+c]]);
        putchar('\n');
    }
}

/*
 * Exact event-order model:
 * - setup creates cells row-major, but Ruffle prepends each MovieClip to
 *   AVM1's global execution list, so onEnterFrame execution is reverse row-major.
 * - a cell takes 9 onEnterFrame calls at speed 10 to move one 90-degree turn.
 * - runFunction() increments score every call, even if the target already has
 *   an active onEnterFrame handler.
 * - if runFunction() happens before a cell's turn in the current frame, that
 *   cell gets its onEnterFrame call immediately; if it happens after its turn,
 *   it waits until the next frame.
 */
static uint64_t simulate(const uint8_t initial[CELLS], int click,
                         uint64_t frame_cap, uint64_t score_cap) {
    int16_t rot[CELLS];
    int16_t angle[CELLS];
    uint8_t active[CELLS];
    for (int i=0;i<CELLS;i++) {
        rot[i] = initial[i];
        angle[i] = (initial[i] == 3) ? -90 : initial[i] * 90;
    }
    memset(active, 0, sizeof active);

    uint64_t score = 1; // cellClick itself sets score = 1.
    rot[click] = (rot[click] + 1) & 3;
    active[click] = 1;

    for (uint64_t frame = 0; frame < frame_cap; ++frame) {
        int any = 0;
        /*
         * Ruffle AVM1's global clip execution list is prepend-only.
         * setup() creates cells row-major, therefore their effective
         * onEnterFrame execution order is reverse row-major.
         *
         * Keep this "live" active[] test: runFunction() may install a
         * handler on a clip that has not yet been visited in this frame,
         * which is observable in this SWF and is required to reproduce
         * the libTAS/Ruffle cascade scores.
         */
        for (int p = CELLS - 1; p >= 0; --p) {
            if (!active[p]) continue;
            any = 1;
            angle[p] += 10;
            if (angle[p] > 180) angle[p] -= 360;
            int target = (rot[p] == 3) ? -90 : rot[p] * 90;
            if (angle[p] != target) continue;

            active[p] = 0; // cellThink clears onEnterFrame before firing neighbors.
            int r = p / N, c = p % N;
            int o = rot[p];

            static const int dr[2][2] = {
                {-1,  0}, // N, E for NE
                { 1,  0}  // S, W for SW -- handled below by orientation
            };
            (void)dr;

            /* The bytecode checks the two exits in this exact order for each orientation. */
            int ns[2][2];
            int count = 0;
            if (o == 3) { // NE: N then E
                ns[count][0] = -1; ns[count++][1] = 0;
                ns[count][0] =  0; ns[count++][1] = 1;
            } else if (o == 0) { // SE: S then E
                ns[count][0] =  1; ns[count++][1] = 0;
                ns[count][0] =  0; ns[count++][1] = 1;
            } else if (o == 1) { // SW: S then W
                ns[count][0] =  1; ns[count++][1] = 0;
                ns[count][0] =  0; ns[count++][1] = -1;
            } else { // NW: N then W
                ns[count][0] = -1; ns[count++][1] = 0;
                ns[count][0] =  0; ns[count++][1] = -1;
            }

            for (int k = 0; k < 2; ++k) {
                int nr = r + ns[k][0], nc = c + ns[k][1];
                if (nr < 0 || nr >= N || nc < 0 || nc >= N) continue;
                int q = nr*N + nc;
                int back = (ns[k][0] ? -ns[k][0] : 0);
                int backc = (ns[k][1] ? -ns[k][1] : 0);
                if (!connects(rot[q], back, backc)) continue;

                /* Direct CallMethod(cell.runFunction): score++ always. */
                if (++score >= score_cap) return score;
                rot[q] = (rot[q] + 1) & 3;
                if (!active[q]) active[q] = 1;
            }
        }
        if (!any) return score;
    }
    return score; // capped by frame_cap; caller can treat this as nonterminal.
}

static uint64_t splitmix64(uint64_t *x) {
    uint64_t z = (*x += 0x9e3779b97f4a7c15ULL);
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
    z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
    return z ^ (z >> 31);
}

static uint64_t now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000ULL + (uint64_t)ts.tv_nsec / 1000ULL;
}


/*
 * Exact libTAS <-> Ruffle timestamp mapping for this setup.
 *
 * libTAS advances two 24-FPS frame boundaries before the SWF's first
 * random(4).  v1.4.7 advances those frames by:
 *
 *     41,666,666 ns + 41,666,667 ns = 83,333,333 ns.
 *
 * Ruffle then calls timestamp_micros(), which truncates to whole us, and
 * finally casts that value to u32.
 *
 * For arbitrary libTAS starting time:
 *
 *     seed = (uint32_t)((start_ns + 83,333,333) / 1000)
 *
 * For searching, we use a canonical inverse whose starting nsec is always
 * a multiple of 1000.  For target absolute RNG microsecond T:
 *
 *     start_us = T - 83,333
 *
 * Then after the exact frame advance the clock is T us + 333 ns, so Ruffle
 * truncates it to exactly T us.  This avoids fragile sub-microsecond start
 * values while still covering every possible nonzero 32-bit Ruffle seed.
 */
#define RNG_STARTUP_US 83333ULL
#define RNG_STARTUP_NS 83333333ULL
#define U32_PERIOD_US  4294967296ULL

static inline uint32_t seed_from_start_time(uint64_t sec, uint64_t nsec) {
    uint64_t start_ns = sec * 1000000000ULL + nsec;
    return (uint32_t)((start_ns + RNG_STARTUP_NS) / 1000ULL);
}

static void start_time_for_seed(uint32_t seed, uint64_t *sec, uint64_t *nsec) {
    /*
     * seed values below 83,333 would otherwise require a negative start.
     * Add one u32 timestamp period; the cast in Ruffle makes it equivalent.
     */
    uint64_t target_us = (uint64_t)seed;
    if (target_us < RNG_STARTUP_US)
        target_us += U32_PERIOD_US;

    uint64_t start_us = target_us - RNG_STARTUP_US;
    *sec = start_us / 1000000ULL;
    *nsec = (start_us % 1000000ULL) * 1000ULL;
}

static void print_start_time_for_seed(uint32_t seed) {
    uint64_t sec, nsec;
    start_time_for_seed(seed, &sec, &nsec);
    printf("STARTING_SYSTEM_TIME=%" PRIu64 "s, %" PRIu64 "nsec\n", sec, nsec);
}


static void usage(const char *p) {
    fprintf(stderr,
      "usage: %s [options]\n"
      "  --seed S          test one raw Ruffle seed (diagnostic)\n"
      "  --start SEC NSEC  test an exact libTAS starting system time\n"
      "  --start-sec S     shorthand for --start S 0\n"
      "  --samples N       number of candidate seeds (default 1000)\n"
      "  --tries N         random clicks per candidate grid (default 4)\n"
      "  --threshold N     full-search threshold (default 1000)\n"
      "  --frames N        per-click frame cap (default 200000)\n"
      "  --score-cap N     stop a simulation at this score (default 100000000)\n"
      "  --all              full-search every sampled grid\n"
      "  --print-board      print the best board\n", p);
}

int main(int argc, char **argv) {
    uint64_t samples = 1000, tries = 4, threshold = 1000;
    uint64_t frame_cap = 200000, score_cap = 100000000;
    int full_all = 0, print_best_board = 0, have_seed = 0;
    uint32_t fixed_seed = 0;

    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--seed") && i+1 < argc) {
            fixed_seed = (uint32_t)strtoull(argv[++i],0,0);
            have_seed=1;
        }
        else if (!strcmp(argv[i], "--start") && i+2 < argc) {
            uint64_t sec = strtoull(argv[++i],0,0);
            uint64_t nsec = strtoull(argv[++i],0,0);
            if (nsec >= 1000000000ULL) {
                fprintf(stderr, "NSEC must be in 0..999999999\n");
                return 1;
            }
            fixed_seed = seed_from_start_time(sec, nsec);
            have_seed=1;
        }
        else if (!strcmp(argv[i], "--start-sec") && i+1 < argc) {
            uint64_t sec = strtoull(argv[++i],0,0);
            fixed_seed = seed_from_start_time(sec, 0);
            have_seed=1;
        }
        else if (!strcmp(argv[i], "--samples") && i+1 < argc) samples=strtoull(argv[++i],0,0);
        else if (!strcmp(argv[i], "--tries") && i+1 < argc) tries=strtoull(argv[++i],0,0);
        else if (!strcmp(argv[i], "--threshold") && i+1 < argc) threshold=strtoull(argv[++i],0,0);
        else if (!strcmp(argv[i], "--frames") && i+1 < argc) frame_cap=strtoull(argv[++i],0,0);
        else if (!strcmp(argv[i], "--score-cap") && i+1 < argc) score_cap=strtoull(argv[++i],0,0);
        else if (!strcmp(argv[i], "--all")) full_all=1;
        else if (!strcmp(argv[i], "--print-board")) print_best_board=1;
        else { usage(argv[0]); return 1; }
    }

    uint64_t master = have_seed ? fixed_seed : now_us();
    uint64_t best_score = 0;
    uint32_t best_seed = 0;
    int best_click = -1;
    uint8_t best_board[CELLS] = {0};

    uint64_t grids = have_seed ? 1 : samples;
    for (uint64_t g = 0; g < grids; ++g) {
        uint32_t seed;
        if (have_seed) {
            seed = fixed_seed;
        } else {
            /*
             * Uniformly sample the full nonzero u32 Ruffle seed space.
             * Every such seed has a canonical libTAS starting time returned by
             * start_time_for_seed(), with nsec aligned to 1 us (multiple of 1000).
             */
            do {
                seed = (uint32_t)splitmix64(&master);
            } while (seed == 0);
        }

        uint8_t board[CELLS];
        board_from_seed(seed, board);
        uint64_t grid_best = 0;

        if (full_all || have_seed) {
            for (int click = 0; click < CELLS; ++click) {
                uint64_t s = simulate(board, click, frame_cap, score_cap);
                if (s > best_score) {
                    best_score=s; best_seed=seed; best_click=click; memcpy(best_board,board,CELLS);
                }
            }
        } else {
            for (uint64_t t = 0; t < tries; ++t) {
                int click = (int)(splitmix64(&master) % CELLS);
                uint64_t s = simulate(board, click, frame_cap, score_cap);
                if (s > grid_best) { grid_best=s; }
                if (s > best_score) {
                    best_score=s; best_seed=seed; best_click=click; memcpy(best_board,board,CELLS);
                }
            }
            if (grid_best >= threshold) {
                uint64_t ss, sn;
                start_time_for_seed(seed, &ss, &sn);
                fprintf(stderr, "threshold hit: start=%" PRIu64 "s,%" PRIu64 "nsec score=%" PRIu64 "; exhaustive 256 clicks\n",
                        ss, sn, grid_best);
                for (int click = 0; click < CELLS; ++click) {
                    uint64_t s = simulate(board, click, frame_cap, score_cap);
                    if (s > best_score) {
                        best_score=s; best_seed=seed; best_click=click; memcpy(best_board,board,CELLS);
                    }
                }
            }
        }
        if ((g & 0x3ff) == 0 || g+1 == grids) {
            uint64_t bs, bn;
            start_time_for_seed(best_seed, &bs, &bn);
            fprintf(stderr, "grid %" PRIu64 "/%" PRIu64 ", best=%" PRIu64
                            " start=%" PRIu64 "s,%" PRIu64 "nsec click=%d (r%d c%d)\n",
                    g+1, grids, best_score, bs, bn, best_click,
                    best_click>=0?best_click/N:-1, best_click>=0?best_click%N:-1);
        }
    }

    printf("BEST_SCORE=%" PRIu64 "\n", best_score);
    print_start_time_for_seed(best_seed);
    printf("CLICK_INDEX=%d ROW=%d COL=%d\n", best_click, best_click/N, best_click%N);
    printf("RUFFLE_SEED_DIAGNOSTIC=%" PRIu32 " (0x%08" PRIx32 ")\n",
           best_seed, best_seed);
    if (print_best_board) print_board(best_board);
    return 0;
}
