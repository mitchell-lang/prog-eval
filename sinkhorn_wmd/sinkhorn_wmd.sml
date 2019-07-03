(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
structure SinkhornWmd :> SINKHORN_WMD =
struct

(* r is a list of length numWords
 * c is a sparse matrix of size numWords * numDocs
 * vecs is a dense matrix of size numWords * numFeatures
 *)
fun sinkhorn_wmd(numDocs, numWords, numFeatures, r, c, vecs, lamb, maxIter) =
    raise Fail "Not Implemented"

end
