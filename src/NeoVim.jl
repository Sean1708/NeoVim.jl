module NeoVim

using Compat
using Docile
import MsgPack
export Nvim, NeoVimError, request

immutable Val{T} end

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("api.jl")

function __init__()
    n, p = Nvim(Val{:Spawn})
    global const API = api_info(n)
    close(n)
    # TODO: do this by sending :q! if possible
    kill(p)

    declare_err(API["error_types"])
    declare_type(API["types"])
    declare_func(API["functions"])
end

immutable NeoVimError <: Exception
    id::Int
    msg::UTF8String
end
@compat NeoVimError(id, msg::Vector{UInt8}) = NeoVimError(id, UTF8String(msg))
NeoVimError(a::Vector) = NeoVimError(a[1], a[2])

function request(n::Nvim, func::ByteString, args...)
    requestid = n.reqid
    n.reqid += 1
    MsgPack.pack(n, Any[0, requestid, func, collect(args)])

    ret = MsgPack.unpack(n)
    ret[3] === nothing || throw(NeoVimError(ret[3]))
    return sanitize(n, ret[4])
end

end # module
