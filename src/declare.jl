#=
 This file declares as much of the Plugin API (as dictated by
 "vim_get_api_info") as possible.
=#

sanedict(d::Dict) = Dict([symbol(k) => sanedict(v) for (k, v) in d])
sanedict(a::Vector) = [sanedict(i) for i in a]
sanedict(a::Vector{UInt8}) = bytestring(a)
sanedict(x) = x

function api_info(n::Nvim)
    MsgPack.pack(n, Any[0, 0, "vim_get_api_info", []])
    return sanedict(MsgPack.unpack(n)[4][2])
end

function declare(n::Nvim)
    @eval const API = api_info($n)
end
