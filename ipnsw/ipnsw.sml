(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
structure Ipnsw :> IPNSW =
struct

val distCount = ref 0;

(*
  Compute the dot product between a query row (specified by index
  into the queries array) and a data row (by index into the given matrix)

  TODO: implement this function. distCount must be incremented for
  each call (as it currently is).
*)
fun queryDist (m, q, row) =
    let
      val _ = distCount := !distCount + 1
    in
      raise Fail "Not Implemented"
    end


(*
  Find the nearest <numResults> vectors in our search space: this function
  should return these items as a list in decreasing order of fitness.

  queryNum: the index of the query vector to run
  gs: the graph hierarchy. The first element is the finest, the last is the coarsest.
  There are a total of four entries in the tree for this dataset.
  startNode: The node to start our search at.
  ef: beam width to limit the search to, as specified in the problem statement
  numResults: number of results to return

  TODO: implement this function
*)
fun runOne (queryNum, graphs, data, queries, startNode, ef, numResults) =
    raise Fail "Not Implemented"


fun run (numQueries, graphs, data, queries, startNode, ef, numResults) =
    let
      fun runLoop n =
          if n >= numQueries
          then []
          else runOne (n, graphs, data, queries, startNode, ef, numResults) :: (runLoop (n + 1))
    in
      (runLoop 0, !distCount)
    end

end
