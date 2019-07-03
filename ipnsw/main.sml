(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
fun splitLine line =
    String.tokens Char.isSpace line;

(* The missing List.appi function: apply a function to each element with its index *)
fun appi (func, ls) =
    let
        fun work (rest, index) =
            case rest of
                nil => ()
              | h::t => ((func (h, index)); (work (t, index + 1)))
    in
        work (ls, 0)
    end

fun listToString (l, conv) = 
    let
        val vals = List.map conv l
        val s = List.foldr (fn (i, s) => (i ^ " " ^ s)) "" vals
    in
        s
    end
        
fun printList (l, conv) =
    print ((listToString (l, conv)) ^ "\n")


(* 
  Read a matrix from a text file of space-separated numbers. For instance,
  a 3x4 matrix of zeros is stored as:

3 4
0 0 0 0
0 0 0 0
0 0 0 0

*)
fun readMatrix filename =
    let
        val fp = TextIO.openIn filename
        val header = valOf (TextIO.inputLine fp)
        val sizes = List.map (fn tok => valOf (Int.fromString tok)) (splitLine header)
        val shape = (List.nth (sizes, 0), List.nth (sizes, 1))
        val mat = Array2.array (#1 shape, #2 shape, 0.0)
        fun oneLine (rowNum) =
            let
                val line = valOf (TextIO.inputLine fp)
                val nums = List.map (fn tok => valOf (Real.fromString tok)) (splitLine line)
            in
                appi ((fn (v, idx) => Array2.update(mat, rowNum, idx, v)), nums)
            end

        fun loop (rowNum) =
            if rowNum >= #1 shape then
                mat
            else
                (oneLine rowNum;
                 loop (rowNum + 1))
    in
        loop 0
    end


fun emptyNodeHash () = HashTable.mkTable ((MLton.hash, op=), 0)
fun emptyEdgeHash () =
    let
        fun order (u,v) = (u, v)
        fun hash e = MLton.hash (order e)
        fun eq (e1, e2) = order e1 = order e2
    in
        HashTable.mkTable ((hash, eq), 0)
    end;
                          

(* 
  Read the graphs from the text representation. Each line is of the form:

<hierarchy-level> <source-node> <dest-node-1> <dest-node-2> ...

  Returns an array of the graphs read.
*)
fun readGraphs filename =
    let
        val fp = TextIO.openIn filename
        val graphs = Array.tabulate (4, (fn _ => DiGraph.empty ()))
        val nodes = Array.tabulate (4, (fn _ => emptyNodeHash ()))
        val edges = Array.tabulate (4, (fn _ => emptyEdgeHash ()))
        fun addEdge (level, source, dest) =
            let
                val n = Array.sub (nodes, level)
                val e = Array.sub (edges, level)
            in
                HashTable.insert (e, ((source, dest), ()));
                HashTable.insert (n, (source, ()));
                HashTable.insert (n, (dest, ()))
            end
        fun oneLine line =
            case List.map (fn tok => valOf (Int.fromString tok)) (splitLine line) of
                level :: source :: dests => List.app (fn dest => addEdge (level, source, dest)) dests
              | _ => raise Fail "Bad input file"
        fun loop () =
            case TextIO.inputLine fp of
                SOME l => (oneLine l; loop ())
              | NONE => Array.tabulate (4, fn i => DiGraph.fromMaps ((Array.sub (nodes, i)), Array.sub (edges, i)))
    in
        loop ()
    end

fun main () =
    let
        val numQueries = 512
        val startNode = 82026
        val ef = 128
        val numResults = 10

        val gs = readGraphs "data/music.graphs.txt";
        val data = readMatrix "data/database_music100.txt";
        val queries = readMatrix "data/query_music100.txt";

        val timer = Timer.startRealTimer()

        val (results, distCount) = Ipnsw.run(numQueries, gs, data, queries, startNode, ef, numResults)

        val elapsed = Time.toReal (Timer.checkRealTimer timer)

        val elapsedOut = TextIO.openOut "results/elapsed"
        val _ = TextIO.output (elapsedOut, Real.toString elapsed)
        val _ = TextIO.closeOut elapsedOut

        val counterOut = TextIO.openOut "results/counter"
        val _ = TextIO.output (counterOut, (Int.toString distCount))
        val _ = TextIO.closeOut counterOut

        val scoresOut = TextIO.openOut "results/scores"
        val _ = List.app (fn l => TextIO.output (scoresOut, (l ^ "\n")))
                         (List.map (fn x => listToString (x, Int.toString)) results)
        val _ = TextIO.closeOut scoresOut
    in
        ()
    end;

main ();
