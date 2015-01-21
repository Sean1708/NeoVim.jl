module NeoVim

import MsgPack
export Nvim, NeoVimError, request

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("api.jl")

function __init__()
    # TODO: have a way to allow users to specify program path
    env = Dict([k => v for (k,v) in ENV])
    env["NVIM_LISTEN_ADDRESS"] = "127.0.0.1:6666"
    v = spawn(setenv(`nvim`, env))
    # TODO: this is a symptom of shoddy design, possibly use --embed
    #       this might also be a bug in `spawn` (^ is still true though)
    sleep(0.001)
    n = Nvim(6666)
    global const API = api_info(n)
    close(n)
    # TODO: do this by sending :q! if possible
    kill(v)

    declare_err(API["error_types"])
    declare_type(API["types"])
    declare_func(API["functions"])
end

immutable NeoVimError <: Exception
    id::Int
    msg::UTF8String
end
NeoVimError(id, msg::Vector{UInt8}) = NeoVimError(id, UTF8String(msg))
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
