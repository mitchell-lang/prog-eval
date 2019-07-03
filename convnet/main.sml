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


(*
  Read a matrix from a text file of space-separated numbers. The first line specifies
  the data dimensions: A 2D array will be returned with #rows = first dimension, #cols =
  product of remaining dimensions (i.e., the tensor is flattened into a 2D matrix)
*)
fun readMatrix filename =
    let
        val fp = TextIO.openIn filename
        val header = valOf (TextIO.inputLine fp)
        val sizes = List.map (fn tok => valOf (Int.fromString tok)) (splitLine header)
        val outer = List.hd sizes
        val entries = List.foldr op* 1 sizes
        val mat = Array.array (entries, 0.0)
        fun oneLine offset =
            let
                val line = valOf (TextIO.inputLine fp)
                val nums = List.map (fn tok => valOf (Real32.fromString tok)) (splitLine line)
                val size = List.length nums
                val _  = appi ((fn (v, idx) => Array.update(mat, offset + idx, v)), nums)
            in
                if offset + size < entries then
                    oneLine (offset + size)
                else
                    mat
            end
        fun split (m, num) =
            let
                val size = Int.div ((Array.length m), num)
                fun sub chunkNum =
                    Array.tabulate (size, fn i => Array.sub (m, chunkNum * size + i))
                val outs = Array.tabulate (num, sub)
            in
                outs
            end
    in
        split (oneLine (0), outer)
    end

fun main () =
    let
        val train = readMatrix "data/cifar2/X_train.txt"
        val train_y = readMatrix "data/cifar2/y_train.txt"
        val test = readMatrix "data/cifar2/X_test.txt"
        val test_y = readMatrix "data/cifar2/y_test.txt"

        val timer = Timer.startRealTimer()
        val preds = Convnet.predict (train, train_y, test, test_y)
        val elapsed = Time.toReal (Timer.checkRealTimer timer)

        val predOut = TextIO.openOut "results/preds"
        val _ = Array.app (fn x => TextIO.output (predOut, (Int.toString x) ^ "\n"))
                          preds
        val _ = TextIO.closeOut predOut

        val elapsedOut = TextIO.openOut "results/elapsed"
        val _ = TextIO.output (elapsedOut, Real.toString elapsed)
        val _ = TextIO.closeOut elapsedOut

    in
        ()
    end;

main ();
