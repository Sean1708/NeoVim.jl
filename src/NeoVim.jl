module NeoVim

import MsgPack
export Nvim, request

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("declare.jl")

function __init__()
    # TODO: what if people already have NVIM_LISTEN_ADDRESS set to an empty string?
    oldaddr = get(ENV, "NVIM_LISTEN_ADDRESS", "")
    ENV["NVIM_LISTEN_ADDRESS"] = "127.0.0.1:6666"

    # TODO: have a way to allow users to specify program path
    v = spawn(`nvim`)
    n = Nvim(6666)
    global const API = sanedict(request(n, "vim_get_api_info")[2])
    kill(v)

    if isempty(oldaddr)
        delete!(ENV, "NVIM_LISTEN_ADDRESS")
    else
        ENV["NVIM_LISTEN_ADDRESS"] = oldaddr
    end
end

type NeoVimException <: Exception
    id::Int
end
# declare Base.showerr in declare()

function request(n::Nvim, func::ByteString, args...)
    requestid = n.id
    n.id += 1
    MsgPack.pack(n, Any[0, requestid, func, collect(args)])

    ret = MsgPack.unpack(n)
    ret[3] === nothing || throw(NeoVimException(ret[3]))
    return ret[4]
end

end # module
