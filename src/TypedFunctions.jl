isdefined(:__precompile__) && __precompile__()

module TypedFunctions

export @typed,
       TypedFunction

import Base.call,
       Base.Func,
       Base.return_types,
       Base.show,
       Base.methods

function toarray(t::Tuple)
    a = DataType[]
    for i in t
        push!(a, i)
    end
    a
end

typealias TypedMethodTable Dict{Function,Array{Method}}

type TypedFunction <: Func
    f::Function
    sig::Tuple
    rtype::Tuple

    function TypedFunction(f, s, r)
        if !(typeof(r) <: Tuple) 
            r = (r,)
        end
        tf = new(f, s, r)
        rets = return_types(tf.f, tf.sig)
        @assert length(rets) == 1 "Function has more than one return type"
        rt = first(rets)
        @show 
        if !(typeof(rt) <: Tuple) 
            rt = (rt,)
        end
        ttype = typeof(tf.rtype)
        @assert typeof(rt) == ttype "Expected return value $rt to be of type $ttype"
        tf
    end
end

function methods(tf::TypedFunction)

end

function show(io::IO, tf::TypedFunction) 
    fname = replace(string(tf.f), "__", "")
    println(io, "$fname (typed function with 11 methods)")
end

# Whether we get a singular typename, a tuple of typenames, we want to resolve everything
# to Vector{DataType}
function resolveReturnType(rt)
    t = typeof(rt)
    if t <: Type
        println("got a singular type")
        return Vector{DataType}([rt])
    elseif typeof(t) == DataType && symbol(t.name) == :Tuple
        println("got a tuple", rt)
        return toarray(rt)
    else 
        error("Invalid return type: $rt")
    end
end

# function TypedFunction(f::Function, sig::Vector{DataType}, rt)
#     t = typeof(rt)
#     if t <: Type
#         println("got a singular type")
#         return TypedFunction(f, sig, Vector{DataType}([rt]))
#     elseif t <: Tuple
#         println("got a tuple")
#         return TypedFunction(f, sig,toarray(rt))
#     else 
#         error("Invalid return type: $rt")
#     end
# end

function call(tf::TypedFunction, x...)
    # @show return_types(tf.f, tf.sig)
    # for (i, typ) in enumerate(return_types(tf.f, tf.sig))
    #     @assert typ <: tf.rtype[i] "Expected return value $i to be of type $(tf.rtype[i])"
    # end
    tf.f(x...)
end

function getsignature(fun::Expr)
    types = Symbol[]
    for param in fun.args[1].args[2:end]
        push!(types, param.args[2])
    end
    tuple(types...)
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
        # typ = typeof(typ) <: Tuple ? [typ...] : typ
        # typ = typeof(typ) <: AbstractVector ? typ : [typ]
        sig = $(esc(map(eval, fsig)))
        $(esc(func))
        $(esc(fname)) = TypedFunction($(esc(fprivate)), sig, typ)
    end
end

end # module
