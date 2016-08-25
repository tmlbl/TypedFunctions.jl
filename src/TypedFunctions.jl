module TypedFunctions

export @typed

import Base.call,
       Base.Func

type TypedFunction <: Func
    f::Function
    rtype::Type
end

call(tf::TypedFunction, x...) = call(tf.f, x...)

macro typed(func)
    @show typeof(func.args[2].args[2].args[1])
    return quote
        $(esc(func))
    end
end

end # module
