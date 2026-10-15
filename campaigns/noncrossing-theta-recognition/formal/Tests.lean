import Challenge
open NoncrossingThetaRecognition
example : sourceWitness ⟨2,[]⟩ [[(0,1),(0,1)]] = true := by native_decide
example : legalSource ⟨3,[(0,1),(1,2),(0,2)]⟩ = false := by native_decide
example : targetWitness ⟨2,[(0,1)]⟩ ⟨[1,1,1,1,1],[[0,1],[1,2]]⟩ = true := by native_decide
example : connectedSet (host [1,1,1,1,1]) [0,3] = false := by native_decide
