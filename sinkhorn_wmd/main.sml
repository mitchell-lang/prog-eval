(* Copyright 2019 Systems & Technology Research. All Rights Reserved. *)
(* helper functions for creating sparse matrix *)
fun for (lo, hi) f =
  let
    fun for' i =
      if i >= hi
      then ()
      else (f i; for' (i+1))
  in
    for' lo
  end

fun read_double1d(vecs, bin, width, j) =
  for (0,width) (fn i => GSL.matrix_set(vecs, Int64.fromInt j, Int64.fromInt i, PackReal64Little.subVec(bin, j*width+i)))

fun read_double2d(vecs, bin, height, width) =
  for (0, height) (fn j => read_double1d(vecs, bin, width, j))

(* read in -vecs.bin file *)
fun read_vecs filename =
  let
    val fp = BinIO.openIn filename
    val sizeVec = BinIO.inputN(fp, 8) (* read height and width (int32, int32) *) 
    val height = Word64.toInt(PackWord32Little.subVec(sizeVec,0))
    val width = Word64.toInt(PackWord32Little.subVec(sizeVec,1))
    val bin = BinIO.inputN(fp, width*height*8) (* read all real64 as binary (8 bytes per double) *)
    val _ = BinIO.closeIn fp
    val vecs = GSL.matrix_alloc(Int64.fromInt(height), Int64.fromInt(width))
    val _ = read_double2d(vecs, bin, height, width)   (* convert binary to list of lists of real64 *)
  in
    (vecs, height, width)
  end

(* read row for -mat.bin file *)
fun read_row(bin, j) =
  let
    val row = Word64.toInt(PackWord32Little.subVec(bin,j*4))
    val col = Word64.toInt(PackWord32Little.subVec(bin,j*4+1))
    val value = PackReal64Little.subVec(bin,j*2+1)
  in
    (row,col,value)
  end

(* read -mat.bin file *)
fun read_mat filename =
  let
    val fp = BinIO.openIn filename
    val sizeVec = BinIO.inputN(fp, 12) (* read height and width (int32, int32) *) 
    val height = Word64.toInt(PackWord32Little.subVec(sizeVec,0))
    val width = Word64.toInt(PackWord32Little.subVec(sizeVec,1))
    val total = Word64.toInt(PackWord32Little.subVec(sizeVec,2))
    val bin = BinIO.inputN(fp, total*4*4) (* read all as binary *)
    val _ = BinIO.closeIn fp
  in
    (List.tabulate(total, (fn j => read_row(bin,j))), height, width, total)
  end

(* convert mat into sparse matrix *)
fun prep_mat(mat_struct, n_docs) =
  let
    val (mat, height, width, total) = mat_struct
    val spmat = GSL.spmatrix_alloc(Int64.fromInt(height), Int64.fromInt(n_docs))
    val relevant_matrix_values = List.filter (fn i => (#2i < n_docs)) mat
    val _ = List.app (fn x => (GSL.spmatrix_set(spmat, Int64.fromInt(#1x), Int64.fromInt(#2x), #3x);())) relevant_matrix_values;
  in
    spmat
  end

(* extract column from sparse matrix *)
fun prep_r(spmat, query_idx, height) =
  List.tabulate(height, (fn j => GSL.spmatrix_get(spmat, Int64.fromInt(j), Int64.fromInt(query_idx))))

(* format output *)
fun replaceChars c =
    case c of
        #"~" => "-"
      | _ => String.str c

fun fmt r = String.translate replaceChars (Real.fmt (StringCvt.SCI (SOME 8)) r)

fun main () =
    let
      (* args *)
      val inpath = "data/cache"
      val n_docs = 5000
      val query_idx = 100
      val lamb = 1
      val max_iter = 16

      (* IO *)
      (* val docs = read_docs(inpath ^ "-docs") *)  (* not used *)
      val (vecs, _, numFeatures) = read_vecs(inpath ^ "-vecs.bin")
      val (mat_struct, numWords, totalNumDocs, total) =  read_mat (inpath ^ "-mat.bin")

      (* Prep *)
      val spmat = prep_mat((mat_struct, numWords, totalNumDocs, total), n_docs)
      val r = prep_r(spmat, query_idx, numWords)

      (* Run *)
      val timer = Timer.startRealTimer()
      val scores = SinkhornWmd.sinkhorn_wmd(n_docs, numWords, numFeatures, r, spmat, vecs, lamb, max_iter)
      val elapsedTime = Time.toReal(Timer.checkRealTimer timer)

      (* Save results *)
      val _ = OS.FileSys.mkDir("results") handle SysErr => ()

      val fp = TextIO.openOut("results/elapsed")
      val _ = TextIO.output(fp, Real.fmt (StringCvt.FIX NONE) elapsedTime ^ "\n")
      val _ = TextIO.closeOut fp

      val fp = TextIO.openOut("results/scores")
      val _ = List.app (fn v => TextIO.output(fp, fmt v ^ "\n")) scores
      val _ = TextIO.closeOut fp
    in
      ()
    end

val _ = main ()
