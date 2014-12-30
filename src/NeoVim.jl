module NeoVim

import MsgPack
export Nvim

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")

sanedict(d::Dict) = Dict([symbol(k) => sanedict(v) for (k, v) in d])
sanedict(a::Vector) = [sanedict(i) for i in a]
sanedict(a::Vector{UInt8}) = bytestring(a)
sanedict(x) = x

function api_info(n::Nvim)
    MsgPack.pack(n, Any[0, 0, "vim_get_api_info", []])
    return sanedict(MsgPack.unpack(n)[4][2])
end

end # module
