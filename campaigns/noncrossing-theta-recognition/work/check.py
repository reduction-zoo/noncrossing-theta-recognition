"""Partial exact interval-dimension-three source oracle."""

import argparse
import json
import subprocess
import sys
from pathlib import Path

import z3


def legal_source(source):
    if not isinstance(source,dict) or set(source) != {"bottom","top","relations"}:
        return False
    p,q,relations = source["bottom"],source["top"],source["relations"]
    return (type(p) is int and p >= 0 and type(q) is int and q >= 0
            and isinstance(relations,list)
            and all(isinstance(pair,list) and len(pair) == 2
                    and type(pair[0]) is int and 0 <= pair[0] < p
                    and type(pair[1]) is int and 0 <= pair[1] < q
                    for pair in relations)
            and len({tuple(pair) for pair in relations}) == len(relations))


def poset_relations(source):
    p = source["bottom"]
    return {(u,p+v) for u,v in source["relations"]}


def direct_intersection(source,orders):
    n = source["bottom"]+source["top"]
    if (not isinstance(orders,list) or len(orders) != 3
            or any(not isinstance(order,list) or len(order) != n
                   or any(not isinstance(pair,list) or len(pair) != 2
                          or any(type(v) is not int or v < 0 for v in pair)
                          or pair[0] > pair[1] for pair in order)
                   for order in orders)):
        return False
    intended = poset_relations(source)
    return all((all(order[u][1] < order[v][0] for order in orders)) == ((u,v) in intended)
               for u in range(n) for v in range(n) if u != v)


def solve_source(source):
    if not legal_source(source):
        raise ValueError("Illegal height-one poset")
    n = source["bottom"]+source["top"]
    left = [[z3.Int(f"l_{r}_{v}") for v in range(n)] for r in range(3)]
    right = [[z3.Int(f"r_{r}_{v}") for v in range(n)] for r in range(3)]
    solver = z3.Solver()
    for r in range(3):
        for v in range(n):
            solver.add(0 <= left[r][v],left[r][v] <= right[r][v],right[r][v] <= 2*n)
    relations = poset_relations(source)
    for u in range(n):
        for v in range(u+1,n):
            if (u,v) in relations:
                solver.add(*[right[r][u] < left[r][v] for r in range(3)])
            else:
                solver.add(z3.Or(*[right[r][u] >= left[r][v] for r in range(3)]))
            if (v,u) in relations:
                solver.add(*[right[r][v] < left[r][u] for r in range(3)])
            else:
                solver.add(z3.Or(*[right[r][v] >= left[r][u] for r in range(3)]))
    result = solver.check()
    if result == z3.unsat:
        return {"status":"NO-SOLUTION"}
    if result != z3.sat:
        raise RuntimeError(f"Inconclusive interval-dimension solver: {result}")
    model = solver.model()
    output = {"interval_orders":[[[model.eval(left[r][v]).as_long(),model.eval(right[r][v]).as_long()]
                                  for v in range(n)] for r in range(3)]}
    assert direct_intersection(source,output["interval_orders"])
    return output


def valid_source(source,output):
    if not legal_source(source) or not isinstance(output,dict):
        return False
    if output == {"status":"NO-SOLUTION"}:
        return solve_source(source) == output
    return set(output) == {"interval_orders"} and direct_intersection(source,output["interval_orders"])


def self_test():
    from generate_cases import EDGE_CASES,random_source
    from test_oracle import test_hand_cases
    path = Path(__file__).with_name("cases.json")
    root = Path(__file__).resolve().parents[3]
    subprocess.run([sys.executable,str(root/"research/validate_preparation.py"),str(path)],check=True,cwd=root)
    cases = json.loads(path.read_text())
    for source,expected in EDGE_CASES:
        assert ("interval_orders" in solve_source(source)) == expected
    for case in cases:
        source = case["source"]
        if case["kind"] == "random":
            assert random_source(case["seed"]) == source
        answer = solve_source(source)
        assert ("interval_orders" in answer) == ("interval_orders" in case["expected"])
        assert valid_source(source,answer) and valid_source(source,case["expected"])
    test_hand_cases()
    print(f"Partial Prepare: {len(cases)} height-one poset source cases checked; theta target oracle pending")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--self-test",action="store_true")
    group.add_argument("--candidate",type=Path)
    args = parser.parse_args()
    if args.self_test:
        self_test()
    else:
        raise SystemExit("Prepare blocked: unbounded theta-host subdivisions need a conclusive target oracle")
