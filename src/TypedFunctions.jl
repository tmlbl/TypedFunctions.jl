module TypedFunctions

export @typed

macro typed(func)
    @show typeof(func.args[2].args[2].args[1])
    return quote
        $(esc(func))
    end
end

end # module
