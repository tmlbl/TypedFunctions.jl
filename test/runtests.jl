using TypedFunctions,
      Base.Test

@typed function add(x::Int64, y::Int64): Int64 
    x + y
end

@test add(2, 3) == 5
@test typeof(add(2, 3)) <: Int64
@test_throws MethodError add("foo")

println("Multiple return types")
@typed function noot(): (Bool, Bool)
    return true, false
end

@test noot() == (true, false)
