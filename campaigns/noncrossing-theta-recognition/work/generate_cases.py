"""Fix seeded height-one interval-dimension source cases."""

import json
import random
from pathlib import Path


def source(p,q,relations):
    return {"bottom":p,"top":q,"relations":sorted(relations)}


def standard_example(n):
    return source(n,n,[[i,j] for i in range(n) for j in range(n) if i != j])


EDGE_CASES = [
    (source(0,0,[]),True),
    (source(1,0,[]),True),
    (source(0,1,[]),True),
    (source(1,1,[]),True),
    (source(1,1,[[0,0]]),True),
    (source(2,1,[[0,0]]),True),
    (source(2,1,[[0,0],[1,0]]),True),
    (source(2,2,[]),True),
    (source(2,2,[[0,0],[1,1]]),True),
    (source(2,2,[[0,0],[0,1],[1,0],[1,1]]),True),
    (standard_example(3),True),
    (standard_example(4),False),
    (source(5,4,standard_example(4)["relations"]),False),
]


def random_source(seed):
    rng = random.Random(seed)
    if seed % 2:
        missing = list(range(4))
        rng.shuffle(missing)
        relations = [[i,j] for i in range(4) for j in range(4) if j != missing[i]]
        relations += [[4,j] for j in range(4) if rng.randrange(2)]
        return source(5,4,relations)
    p,q = rng.randint(1,4),rng.randint(1,4)
    relations = set()
    for _ in range(3):
        bottom_right = [rng.randint(1,9) for _ in range(p)]
        top_left = [rng.randint(1,9) for _ in range(q)]
        current = {(i,j) for i in range(p) for j in range(q)
                   if bottom_right[i] < top_left[j]}
        relations = current if _ == 0 else relations & current
    return source(p,q,[list(pair) for pair in relations])


def build_cases():
    from check import solve_source
    cases,seen = [],set()

    def add(instance,kind,seed=None,expected=None):
        key = json.dumps(instance,sort_keys=True,separators=(",",":"))
        if key in seen:
            return False
        answer = solve_source(instance)
        if expected is not None and ("interval_orders" in answer) != expected:
            raise AssertionError(f"Hand label disagrees with oracle: {instance}")
        seen.add(key)
        case = {"source":instance,"kind":kind,"expected":answer}
        if seed is not None:
            case["seed"] = seed
        cases.append(case)
        return True

    for instance,expected in EDGE_CASES:
        add(instance,"edge",expected=expected)
    seed = 0
    while sum(case["kind"] == "random" for case in cases) < 100:
        add(random_source(seed),"random",seed=seed)
        seed += 1
    return cases


if __name__ == "__main__":
    path = Path(__file__).with_name("cases.json")
    cases = build_cases()
    path.write_text(json.dumps(cases,indent=2)+"\n")
    print(f"Wrote {len(cases)} cases to {path}")
