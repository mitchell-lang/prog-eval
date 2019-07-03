signature RECSYS =
sig
  val predict : Real32.real array array * int * int * int * Real32.real * Real32.real * Real32.real -> Real32.real array array
end
