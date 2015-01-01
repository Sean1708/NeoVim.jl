module NeoVim

import MsgPack
export Nvim, request

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("declare.jl")

function __init__()
    # TODO: have a way to allow users to specify program path
    v = spawn(setenv(`nvim`, vcat(
        ["$(k)=$(v)" for (k, v) in ENV],
        "NVIM_LISTEN_ADDRESS=127.0.0.1:6666"
    )))
    n = Nvim(6666)
    global const API = sanedict(request(n, "vim_get_api_info")[2])
    close(n)
    # TODO: do this by sending :q! if possible
    kill(v)

    declare_err(API)
end

immutable NeoVimError <: Exception
    id::Int
    msg::UTF8String
end
NeoVimError(id, msg::Vector{UInt8}) = NeoVimError(id, UTF8String(msg))
NeoVimError(a::Vector) = NeoVimError(a[1], a[2])

function request(n::Nvim, func::ByteString, args...)
    requestid = n.id
    n.id += 1
    MsgPack.pack(n, Any[0, requestid, func, collect(args)])

    ret = MsgPack.unpack(n)
    ret[3] === nothing || throw(NeoVimError(ret[3]))
    return ret[4]
end

end # module
