using TypedFunctions,
      Base.Test

@typed function add(x::Real, y::Real): Real 
    x + y
end

@test add(2, 3) == 5
