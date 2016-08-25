isdefined(:__precompile__) && __precompile__()

module TypedFunctions

export @typed,
       TypedFunction

import Base.call,
       Base.Func,
       Base.return_types

type TypedFunction <: Func
    f::Function
    sig::Vector{DataType}
    rtype::Vector{DataType}
end

function TypedFunction(f, s, r)
    @show s 
    @show r
end

# TypedFunction(f::Function, r::Type) = TypedFunction(f, [r])

function call(tf::TypedFunction, x...)
    for (i, typ) in enumerate(return_types(tf.f, tf.sig))
        @assert typ <: tf.rtype[i] "Expected return value $i to be of type $(tf.rtype[i])"
    end
    tf.f(x...)
end

function getsignature(fun::Expr)
    types = Symbol[]
    for param in fun.args[1].args[2:end]
        push!(types, param.args[2])
    end
    types
end

macro typed(func)
    # Create a private name for the underlying function
    fname = func.args[1].args[1]
    fprivate = symbol("__$fname")
    func.args[1].args[1] = fprivate
    # Get the type annotation
    typeAnno = func.args[2].args[2].args[1]
    # Get the function signature 
    fsig = getsignature(func)
    return quote
        typ = $(esc(typeAnno))
        typ = typeof(typ) <: AbstractVector ? typ : [typ]
        sig = $(esc(map(eval, fsig)))
        $(esc(func))
        $(esc(fname)) = TypedFunction($(esc(fprivate)), sig, typ)
    end
end

end # module
