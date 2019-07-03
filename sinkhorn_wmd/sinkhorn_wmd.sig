signature SINKHORN_WMD =
sig

  val sinkhorn_wmd : int * int * int * real list * GSL.SpMatrix * GSL.Matrix * int * int -> real list

end
