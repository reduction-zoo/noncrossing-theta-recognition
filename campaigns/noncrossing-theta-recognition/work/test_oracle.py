from check import solve_source,valid_source


def test_hand_cases():
    relation = {"bottom":1,"top":1,"relations":[[0,0]]}
    assert valid_source(relation,{"interval_orders":[[[0,0],[1,1]]]*3})
    assert not valid_source(relation,{"interval_orders":[[[0,1],[1,2]]]*3})
    four = {"bottom":4,"top":4,"relations":[[i,j] for i in range(4) for j in range(4) if i != j]}
    assert solve_source(four) == {"status":"NO-SOLUTION"}


if __name__ == "__main__":
    test_hand_cases()
