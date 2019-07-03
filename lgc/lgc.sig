signature LGC =
sig
  val parallelPrNibble : (int list * (unit, unit) BaseGraph.t * real * real) -> real array list
  val ista : (int list * (unit, unit) BaseGraph.t * real * real * int) -> real array list
end
