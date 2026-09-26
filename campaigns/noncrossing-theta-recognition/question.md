# Height-one poset interval dimension at most three → Non-crossing theta-host recognition

Category: Complexity open

## Source

The source is an explicitly encoded height-one poset. Its outputs are at most three interval orders whose intersection is that poset, or NO-SOLUTION.

## Target

The fixed host has one a–b edge, three parallel b–c edges, and one c–d edge. Represent the target graph by connected subgraphs of a subdivision of this host, with intersection exactly adjacency and each pairwise set difference connected or empty.

## Required result

Construct deterministic polynomial-time maps F and G: F sends every legal source instance to a legal target instance, and G(x,y) is a valid source output for every valid output y of F(x). Preserve the stated threshold, domain and promises. The requested complexity conclusion is NP-hardness for the stated target problem.

## Acceptance

Give explicit construction and recovery algorithms, a general proof for every legal input and every valid target output, and polynomial runtime and encoding-size bounds. Specify finite output encodings and handle NO-SOLUTION outputs when applicable. Tests compare recovered source outputs with independent source solutions.

## Why it matters

This tests recognition on a small host where branching and non-crossing constraints interact.

## Difficulty

Interval-dimension encodings must survive subdivision freedom and alternative host representations.

## Literature context

The question fixes a particular small host and the non-crossing condition. General intersection-graph recognition does not establish this restriction.

Literature checked 2026-09-16. This summarizes the archived literature search on the date above. Unpublished, unindexed and overlooked work remains outside coverage; no new novelty assessment was performed.

## References

- [Non-crossing H-graphs](https://arxiv.org/html/2501.11192v2): Bonomo-Braberman, Brettell, Munaro and Paulusma, Non-crossing H-graphs, Definition 3 and Section 5, Open Problem 1, ask whether any fixed H has NP-complete non-crossing recognition. Their Definition 2 and Appendix A show that proper and non-crossing representations cannot be conflated. The fixed D above is a concrete candidate for this general question, not a host singled out by the open-problem statement.
- [Recognizing Proper Tree-Graphs](https://arxiv.org/pdf/2011.11670): Chaplick, Golovach, Hartmann and Knop, Recognizing Proper Tree-Graphs, Section 5, Theorem 2, pp. 25–28 of the preprint, prove NP-completeness for proper D-graphs. Their construction uses three parallel host paths to represent three interval orders. Pendant host edges remove containments within the two sides. Properness only forbids strict set containment; it does not ensure that set differences remain connected. This is the precise missing implication.

Fixed from board record `website/questions/noncrossing-theta-recognition.json` in board checkout at 6c7d3bd9c0a8f595279969a9c0a4d1853a3f5c17; the record was copied from the current working tree.
