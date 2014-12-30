module NeoVim

import MsgPack
export Nvim, request

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("declare.jl")

# uncomment this when we're sure the module can be cached
#function __init__() end

type NeoVimException <: Exception end

function request(n::Nvim, func::ByteString, args...)
    requestid = n.id
    n.id += 1
    MsgPack.pack(n, Any[0, requestid, func, collect(args)])

    ret = MsgPack.unpack(n)
    ret[3] === nothing || throw(NeoVimException()) #throw(NeoVimException(ret[3])
    return ret[4]
end

end # module
