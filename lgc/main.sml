(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
(* Run *)

(* def parse_args(): *)
(*     parser = argparse.ArgumentParser() *)
(*     parser.add_argument('--num-seeds', type=int, default=50) *)
(*     parser.add_argument('--alpha', type=float, default=0.15) *)
(*     parser.add_argument('--pnib-epsilon', type=float, default=1e-6) *)
(*     parser.add_argument('--ista-rho', type=float, default=1e-5) *)
(*     parser.add_argument('--ista-iters', type=int, default=50) *)
(*     args = parser.parse_args() *)

(*     # !! In order to check accuracy, you _must_ use these parameters !! *)
(*     assert args.num_seeds == 50 *)
(*     assert args.alpha == 0.15 *)
(*     assert args.pnib_epsilon == 1e-6 *)
(*     assert args.ista_rho == 1e-5 *)
(*     assert args.ista_iters == 50 *)

(*     return args *)

structure Mtx =
struct

fun readLines (stream : TextIO.instream) : string list =
    let
      fun go acc =
          case TextIO.inputLine stream of
              NONE => List.rev acc
            | SOME line => go (line::acc)
    in
      go []
    end

fun readFileLines (name : string) : string list =
    let
      val stream = TextIO.openIn name
      val lines = readLines stream
    in
      (TextIO.closeIn stream; lines)
    end

fun skipComments (lines : string list) : string list =
    List.filter (not o String.isPrefix "%") lines

fun parseHeader (header : string) : int * int =
    case String.tokens Char.isSpace header of
        [rows,cols,entries] => (case (Int.fromString rows, Int.fromString entries) of
                                    (SOME r, SOME e) => (r, e)
                                  | _ => raise Fail "Bad MTX header")
      | _ => raise Fail "Bad MTX header"

fun createNodeTable (size : int) : (int, unit) HashTable.hash_table =
    let
      val table = HashTable.mkTable ((MLton.hash, op=), size)
      fun createTableHelper n =
          if n >= size
          then ()
          else (HashTable.insert (table, (n, ())); createTableHelper (n+1))
    in
      (createTableHelper 0; table)
    end

fun createEdgeTable (data : string list, numEdges : int) : ((int * int), unit) HashTable.hash_table =
    let
      fun orderPair (x, y) = if x < y then (x, y) else (y, x)
      val edgeMap = HashTable.mkTable ((MLton.hash o orderPair, fn (x,y) => orderPair x = orderPair y), numEdges)
      fun addEdgeHelper line =
          case List.map Int.fromString (String.tokens Char.isSpace line) of
              (* Reindex nodes starting at 0 *)
              [SOME src, SOME dst, SOME 1] => HashTable.insert (edgeMap, ((src-1, dst-1), ()))
            | [SOME src, SOME dst, SOME 0] => ()
            | _ => raise Fail "Bad MTX data"
    in
      (List.app addEdgeHelper data; edgeMap)
    end

fun fromFile (name : string) : (unit, unit) BaseGraph.t =
    let
      val lines = skipComments (readFileLines name)
    in
      case lines of
          [] => raise Fail "Empty MTX file"
        | header::data =>
          let
            val (numNodes, numEdges) = parseHeader header
            val nodeMap = createNodeTable numNodes
            val edgeMap = createEdgeTable (data, numEdges)
          in
            BaseGraph.fromMaps (nodeMap, edgeMap)
          end
    end
end

open Posix.FileSys.S

fun createDir name =
      if Posix.FileSys.access ("results", [])
      then ()
      else Posix.FileSys.mkdir ("results", Posix.FileSys.S.flags [irusr, iwusr, ixusr, irgrp, ixgrp, iroth, ixoth])

fun range (lo, hi) =
    let
      fun go (n, acc) =
          if n >= hi
          then List.rev acc
          else go (n+1, n::acc)
    in
      go (lo, [])
    end

structure PageRankIO =
struct

fun replaceChars c =
    case c of
        #"~" => "-"
      | _ => String.str c

fun fmt r = String.translate replaceChars (Real.fmt (StringCvt.SCI (SOME 18)) r)

fun outputRow (stream, data, row) =
    let
      fun outputEntry p = TextIO.output (stream, fmt (Array.sub (p, row)) ^ " ")
    in
      (List.app outputEntry data; TextIO.output (stream, "\n"))
    end

fun output (stream, size, data) =
    let
      fun go r =
          if r >= size
          then ()
          else (outputRow (stream, data, r); go (r+1))
    in
      go 0
    end

end

fun main () =
    let
(*     args = parse_args() *)
      val seeds = 50
      val alpha = 0.15
      val pnibEpsilon = 0.000001
      val istaRho = 0.00001
      val istaIters = 50

(* IO *)
      val graph = Mtx.fromFile "data/jhu.mtx"
      val _ = createDir "results"

(* PNIB: Use first `num_seeds` nodes as seeds *)
      val pnibSeeds = range (0, seeds)

(* Run Parallel PR-Nibble *)
      val timer = Timer.startRealTimer ()
      val pnibScores = Lgc.parallelPrNibble (pnibSeeds, graph, alpha, pnibEpsilon)
      val pnibElapsedTime = Time.toReal (Timer.checkRealTimer timer)

(* Write PR-Nibble output *)
      val _ = TextIO.output (TextIO.stdErr, ("parallel_pr_nibble: elapsed = " ^ Real.fmt (StringCvt.FIX NONE) pnibElapsedTime ^ "\n"))
      val pnibElapsedOutput = TextIO.openOut "results/pnib_elapsed"
      val _ = TextIO.output (pnibElapsedOutput, Real.fmt (StringCvt.FIX NONE) pnibElapsedTime ^ "\n")
      val _ = TextIO.closeOut pnibElapsedOutput
      val pnibOutput = TextIO.openOut "results/pnib_score.txt"
      val _ = PageRankIO.output (pnibOutput, BaseGraph.numberOfNodes graph, pnibScores)
      val _ = TextIO.closeOut pnibOutput

(* Run ISTA *)
(* ISTA: Faster algorithm, so use more seeds to get roughly comparable total runtime *)
      val ista_seeds = range(0, 10 * seeds)

      val timer = Timer.startRealTimer ()
      val istaScores = Lgc.ista (ista_seeds, graph, alpha, istaRho, istaIters)
      val istaElapsedTime = Time.toReal (Timer.checkRealTimer timer)

(* Write ISTA output *)
      val _ = TextIO.output (TextIO.stdErr, ("parallel_pr_nibble: elapsed = " ^ Real.fmt (StringCvt.FIX NONE) istaElapsedTime ^ "\n"))
      val istaElapsedOutput = TextIO.openOut "results/ista_elapsed"
      val _ = TextIO.output (istaElapsedOutput, Real.fmt (StringCvt.FIX NONE) istaElapsedTime ^ "\n")
      val _ = TextIO.closeOut istaElapsedOutput
      val istaOutput = TextIO.openOut "results/ista_score.txt"
      val _ = PageRankIO.output (istaOutput, BaseGraph.numberOfNodes graph, istaScores)
      val _ = TextIO.closeOut istaOutput
    in
      ()
    end

val _ = main ()
