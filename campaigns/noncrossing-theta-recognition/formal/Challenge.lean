module

public import Mathlib.Computability.TuringMachine.Computable

@[expose] public section

namespace NoncrossingThetaRecognition

/-- Q001's self-delimiting binary natural; length is logarithmic, not unary. -/
def encodeNat (n : Nat) : List Bool :=
  let bits := (Nat.toDigits 2 n).map (fun c => c == '1')
  List.replicate bits.length true ++ [false] ++ bits

def encodeList {α : Type} (encode : α → List Bool) (xs : List α) : List Bool :=
  encodeNat xs.length ++ xs.flatMap encode

def encodeOption {α : Type} (encode : α → List Bool) : Option α → List Bool
  | none => [false]
  | some x => true :: encode x

/-- None denotes mathematical nonexistence, never an execution error. -/
def searchOutput {I W : Type} (legal : I → Bool) (witness : I → W → Bool)
    (x : I) : Option W → Prop
  | some w => legal x = true ∧ witness x w = true
  | none => legal x = true ∧ ¬ ∃ w, witness x w = true

/-- Relational version for witnesses with quantified real or optimality conditions. -/
def relationalOutput {I W : Type} (legal : I → Bool) (witness : I → W → Prop)
    (x : I) : Option W → Prop
  | some w => legal x = true ∧ witness x w
  | none => legal x = true ∧ ¬ ∃ w, witness x w

structure Graph where
  n : Nat
  edges : List (Nat × Nat)
  deriving Repr

def adjacent (g : Graph) (u v : Nat) : Bool :=
  g.edges.any (fun e => (e.1 == u && e.2 == v) || (e.1 == v && e.2 == u))

def simple (g : Graph) : Bool :=
  g.edges.all (fun e => e.1 < g.n && e.2 < g.n && e.1 != e.2) &&
  decide ((g.edges.map (fun e => (min e.1 e.2, max e.1 e.2))).Nodup)

/-- Vertices at distance at most the supplied bound, including the starting set. -/
def ballFrom (g : Graph) : Nat → List Nat → List Nat
  | 0, seen => seen
  | k + 1, seen => ballFrom g k ((List.range g.n).filter (fun v =>
      seen.contains v || seen.any (fun u => adjacent g u v)))

def connected (g : Graph) : Bool :=
  g.n > 0 && (ballFrom g g.n [0]).length == g.n

def diameterAtMost (g : Graph) (d : Nat) : Bool :=
  (List.range g.n).all (fun v => (ballFrom g d [v]).length == g.n)

def radiusAtMost (g : Graph) (r : Nat) : Bool :=
  (List.range g.n).any (fun v => (ballFrom g r [v]).length == g.n)

def boolWords : Nat → List (List Bool)
  | 0 => [[]]
  | n + 1 => (boolWords n).flatMap (fun xs => [false :: xs, true :: xs])

def bipartite (g : Graph) : Bool :=
  (boolWords g.n).any (fun side => g.edges.all (fun e => side[e.1]? != side[e.2]?))

def crossingDegree (g : Graph) (side : List Bool) (v : Nat) : Nat :=
  ((List.range g.n).filter (fun u => adjacent g u v && side[u]? != side[v]?)).length

def nontrivialCut (g : Graph) (side : List Bool) : Bool :=
  side.length == g.n && side.contains true && side.contains false

def perfectCut (g : Graph) (side : List Bool) : Bool :=
  nontrivialCut g side && (List.range g.n).all (fun v => crossingDegree g side v == 1)

def boundedCut (g : Graph) (d : Nat) (side : List Bool) : Bool :=
  nontrivialCut g side && (List.range g.n).all (fun v => crossingDegree g side v ≤ d)

def encodeGraph (g : Graph) : List Bool :=
  encodeList encodeNat (List.range g.n) ++
  encodeList (fun e => encodeNat e.1 ++ encodeNat e.2) g.edges

structure PosetData where
  n : Nat
  less : List (Nat × Nat)
  deriving Repr
def precedes (x : PosetData) (a b : Nat) : Bool := x.less.contains (a,b)
def legalSource (x : PosetData) : Bool :=
  x.less.all (fun e => e.1 < x.n && e.2 < x.n && e.1 != e.2) && decide x.less.Nodup &&
  (List.range x.n).all (fun a => (List.range x.n).all (fun b => (List.range x.n).all (fun c =>
    !(precedes x a b && precedes x b c))))
abbrev IntervalOrder := List (Nat × Nat)
def sourceWitness (x : PosetData) (orders : List IntervalOrder) : Bool := orders.length ≤ 3 &&
  orders.all (fun order => order.length == x.n && order.all (fun p => p.1 ≤ p.2 && p.2 < 2*x.n)) &&
  (List.range x.n).all (fun a => (List.range x.n).all (fun b =>
    precedes x a b == orders.all (fun order => (order[a]?.getD (0,0)).2 < (order[b]?.getD (0,0)).1)))
def legalTarget := simple
structure Representation where
  lengths : List Nat
  sets : List (List Nat)
  deriving Repr
def chainEdges (vertices : List Nat) := vertices.zip vertices.tail
def host (lengths : List Nat) : Graph :=
  let baseEdges := [(0,1),(1,2),(1,2),(1,2),(2,3)]
  ⟨4+(lengths.map (·-1)).sum,
    (baseEdges.zipIdx).flatMap (fun (e,i) =>
      let offset := 4+((lengths.take i).map (·-1)).sum
      chainEdges ([e.1] ++ (List.range ((lengths[i]?.getD 1)-1)).map (offset+·) ++ [e.2]))⟩
def connectedSet (g : Graph) (s : List Nat) : Bool :=
  s.isEmpty || (ballFrom ⟨g.n,g.edges.filter (fun e => s.contains e.1 && s.contains e.2)⟩ g.n [s.head?.getD 0]).length == s.length
def targetWitness (g : Graph) (w : Representation) : Bool :=
  w.lengths.length == 5 && w.lengths.all (· > 0) && w.sets.length == g.n &&
  w.sets.all (fun s => !s.isEmpty && decide s.Nodup && s.all (· < (host w.lengths).n) && connectedSet (host w.lengths) s) &&
  (List.range g.n).all (fun i => (List.range g.n).all (fun j =>
    let a := w.sets[i]?.getD []
    let b := w.sets[j]?.getD []
    (i == j || adjacent g i j == a.any b.contains) &&
    connectedSet (host w.lengths) (a.filter (fun v => !b.contains v))))
def validSourceOutput := searchOutput legalSource sourceWitness
def validTargetOutput := searchOutput legalTarget targetWitness
def encodeSource (x : PosetData) := encodeList encodeNat (List.range x.n) ++ encodeList (fun e => encodeNat e.1 ++ encodeNat e.2) x.less
def encodeTarget := encodeGraph
def encodeSourceWitness := encodeList (encodeList (fun p : Nat × Nat => encodeNat p.1 ++ encodeNat p.2))
def encodeTargetWitness (w : Representation) := encodeList encodeNat (List.range (host w.lengths).n) ++ encodeList encodeNat w.lengths ++ encodeList (encodeList encodeNat) w.sets

/-- Both algorithms use Q001's explicit bit encoding and TM2 cost model.
Recovery receives the full pair of source instance and target output. -/
def Reduction (forward : PosetData → Graph)
    (recover : PosetData × Option Representation → Option (List IntervalOrder)) : Prop :=
  Nonempty (Turing.TM2ComputableInPolyTime encodeSource encodeTarget forward) ∧
  Nonempty (Turing.TM2ComputableInPolyTime
    (fun input => encodeSource input.1 ++ (encodeOption encodeTargetWitness) input.2)
    (encodeOption encodeSourceWitness) recover) ∧
  (∃ bound : Polynomial Nat, ∀ x,
    (encodeTarget (forward x)).length ≤ bound.eval (encodeSource x).length) ∧
  (∃ bound : Polynomial Nat, ∀ input,
    ((encodeOption encodeSourceWitness) (recover input)).length ≤
      bound.eval (encodeSource input.1 ++ (encodeOption encodeTargetWitness) input.2).length) ∧
  (∀ x, legalSource x = true → legalTarget (forward x) = true) ∧
  (∀ x, legalSource x = true → ∀ y, validTargetOutput (forward x) y →
    validSourceOutput x (recover (x, y)))


def Goal : Prop :=
  ∃ (forward : PosetData → Graph)
    (recover : PosetData × Option Representation → Option (List IntervalOrder)), Reduction forward recover

/-- Open question only; this placeholder is not a solution. -/
theorem solve : Goal := by
  sorry

end NoncrossingThetaRecognition
