#=
 This file declares as much of the Plugin API (as dictated by
 "vim_get_api_info") as possible.
=#

sanedict(d::Dict) = Dict([symbol(k) => sanedict(v) for (k, v) in d])
sanedict(a::Vector) = [sanedict(i) for i in a]
sanedict(a::Vector{UInt8}) = bytestring(a)
sanedict(x) = x

api_info(n::Nvim) = sanedict(request(n, "vim_get_api_info")[2])

function declare_err(api::Dict)
    # TODO:
     # I'm certain there's a type which is an optimized Dict for small maps which I could use here
     # OR: there must be some way I could unroll this (maybe @nifs?)
     # AND: I would rather use UTF8String(k) below but currently that throws MethodError
    @eval begin
        function Base.showerror(io::IO, err::NeoVimError)
            errmap = $(Dict([v[:id] => string(k) for (k, v) in api[:error_types]]))
            name = errmap[err.id]
            print(io, string("NeoVim ", name, " error: ", err.msg))
        end
    end
end
