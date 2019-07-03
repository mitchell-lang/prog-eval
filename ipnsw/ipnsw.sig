signature IPNSW =
sig

  val run : int * ((unit, unit) DiGraph.t) array * real Array2.array * real Array2.array * int * int * int -> (int list) list * int

end
