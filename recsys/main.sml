(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
open Posix.FileSys.S

fun createDir name =
      if Posix.FileSys.access ("results", [])
      then ()
      else Posix.FileSys.mkdir ("results", Posix.FileSys.S.flags [irusr, iwusr, ixusr, irgrp, ixgrp, iroth, ixoth])

fun load file =
  let
    val instream = TextIO.openIn file
    fun readLines acc =
        case TextIO.inputLine instream of
            NONE => acc
          | SOME line =>
            let
              val lineData = List.map (Option.valOf o Int.fromString)
                                      (String.tokens Char.isSpace line)
            in
              readLines (lineData :: acc)
            end
    val data = List.rev (readLines [])
    val _ = TextIO.closeIn instream
    val max = List.foldl (fn (data, m) => (List.foldl Int.max m data)) 0 data
  in
    (data, max)
  end

fun arrayOfList max data =
  let
    val arr = Array.array (max, Real32.fromInt 0)
  in
    (List.app (fn i => Array.update (arr, i-1, Real32.fromInt 1)) data; arr)
  end

fun arrayOfLists (data, max) =
    Array.fromList (List.map (arrayOfList max) data)

structure Topk =
struct
(* The size biggest elements, with the worst element at 0 and the best at size-1. *)
  type t = {size: int ref, arr: (int * Real32.real) array}

  fun new k = {size=ref 0, arr=Array.array (k, (~1, Real32.negInf))}

  fun full {size, arr} = !size = Array.length arr

  (* If it isn't full, there isn't a worst element yet. *)
  fun worst {size, arr} =
      if not (full {size=size, arr=arr})
      then NONE
      else SOME (Array.sub (arr, 0))

  (* If it is full, replace the element at 0. Otherwise, add a new worst. *)
  fun replaceWorst ({size, arr}, v) =
      if full {size=size, arr=arr}
      then Array.update (arr, 0, v)
      else (Array.update (arr, Array.length arr - !size - 1, v); size := !size + 1)

  fun swap (arr, i, j) =
      let
        val xi = Array.sub (arr, i)
        val xj = Array.sub (arr, j)
      in
        (Array.update (arr, i, xj);
         Array.update (arr, j, xi))
      end

  (* Move the element in the 0 slot to where it belongs by repeatedly swapping. *)
  fun fixup {size, arr} =
      let
        (* Move the element in the k slot to where it belongs by repeatedly swapping. *)
        fun fixup' k =
            if k >= (!size - 1)
            then ()             (* there is no better element to swap with *)
            else
              let
                val (i, x) = Array.sub (arr, k)
                val (j, y) = Array.sub (arr, k+1)
              in
                (if x > y       (* if the element at k is better than the one at k+1, swap them *)
                 then swap (arr, k, k+1)
                 else ();
                 fixup' (k+1))
              end
      in
        fixup' 0
      end

  (* If the inserted element is better than the worst, replace the worst with it and fixup. *)
  fun insert topk ((i, x) : int * Real32.real) =
      case worst topk of
          NONE => replaceWorst (topk, (i, x))
        | SOME (_, y) => if x > y
                         then (replaceWorst (topk, (i, x)); fixup topk)
                         else ()

  (* The input 1-indexed, so convert back to that on output. *)
  fun output (outputStream, {size, arr}) =
      ArraySlice.app (fn (i, _) => (TextIO.output (outputStream, Int.toString (i+1)); TextIO.output (outputStream, " ")))
                     (ArraySlice.slice (arr, 0, SOME (!size)))
end

(* data are the original values which are 1-indexed, indicies of predictions are 0-indexed *)
fun topk (data, prediction, k) =
  let
    val tops = Topk.new k
    fun insert (i, x, avoid) =
        case avoid of
            [] => (Topk.insert tops (i, x); [])
          | y::avoid' =>
            case Int.compare (i+1, y) of (* +1 to reconcile different indexing schemes *)
                LESS => (Topk.insert tops (i, x); avoid)
              | EQUAL => avoid'
              | GREATER => (Topk.insert tops (i, x); avoid')
  in
    (Array.foldli insert (ListMergeSort.uniqueSort Int.compare data) prediction; tops)
  end

fun appi (f : int * 'a -> unit) (lst : 'a list) : unit =
    let
      fun appi' (lst, i) =
          case lst of
              [] => ()
            | x :: lst' => (f (i, x); appi' (lst', i+1))
    in
      appi' (lst, 0)
    end

fun outputResult (outputStream, data, prediction, k) =
    let
      val top = topk (data, prediction, k)
    in
      (Topk.output (outputStream, top);
       TextIO.output (outputStream, "\n"))
    end

fun outputResults (outputStream, data, predictions, k) =
  appi (fn (i, d) => outputResult (outputStream, d, Array.sub (predictions, i), k)) data


fun main () =
  let
    val cachePath = "data/cache"
    val batchSize = 256
    val embDim = 800
    val hiddenDim = 400
    val lr = 0.01
    val biasOffset = ~10.0
    val dropout = 0.5
    val k = 10

    (* create the output dir *)
    val _ = createDir "results"

    (* prep the data *)
    val _ = TextIO.output (TextIO.stdErr, "loading data\n")
    val (data, max) = load (cachePath ^ "_train.txt")
    val arr = arrayOfLists (data, max)

    (* run the algorithm *)
    val _ = TextIO.output (TextIO.stdErr, "running\n")
    val timer = Timer.startRealTimer ()
    val predictions = Recsys.predict (arr, batchSize, embDim, hiddenDim, lr, biasOffset, dropout)
    val elapsedTime = Time.toReal (Timer.checkRealTimer timer)

    (* elapsed time *)
    val _ = TextIO.output (TextIO.stdErr, ("elapsed = " ^ Real.fmt (StringCvt.FIX NONE) elapsedTime ^ "\n"))
    val elapsedOutput = TextIO.openOut "results/elapsed"
    val _ = TextIO.output (elapsedOutput, Real.fmt (StringCvt.FIX NONE) elapsedTime ^ "\n")
    val _ = TextIO.closeOut elapsedOutput

    (* results *)
    val _ = TextIO.output (TextIO.stdErr, "writing results\n")
    val outputStream = TextIO.openOut "results/topk"
    val _ = outputResults (outputStream, data, predictions, k)
    val _ = TextIO.closeOut outputStream
  in
    ()
  end

val _ = main ()
