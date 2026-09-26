# Partial contract

Source input is a height-one poset `{"bottom":p,"top":q,"relations":[[bottom_index,top_index],...]}`. A positive output `{"interval_orders":[[[left,right] by element], ...]}` contains exactly three interval orders, each with integer endpoint ranks and `left<=right`. Their strict interval precedence relation, `right(u)<left(v)`, must intersect to exactly the given poset; fewer than three orders can be repeated. `NO-SOLUTION` is valid exactly when no such three-order representation exists.

The target is the graph-only non-crossing intersection representation on a subdivision of the fixed host with one a–b edge, three parallel b–c edges and one c–d edge. A finite subdivision and subgraph witness encoding, conclusive target NO oracle and candidate recovery contract remain to be fixed. `check.py --candidate` exits with the blocker.
