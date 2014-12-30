@doc doc"""Represents a NeoVim buffer.""" ->
type Buffer
    nvim::Nvim
    ext::MsgPack.Ext
end

Base.length(b::Buffer) = :buffer_line_count

Base.getindex(b::Buffer, idx::Integer) = :buffer_get_line
Base.getindex(b::Buffer, rng::Range) = :buffer_get_line_slice
Base.getindex(b::Buffer, var::Symbol) = :buffer_get_var
# possibly a getoption instead
Base.getindex(b::Buffer, opt::ByteString) = :buffer_get_option

Base.setindex!(b::Buffer, val, idx::Integer) = :buffer_set_line
Base.setindex!(b::Buffer, val, rng::Range) = :buffer_set_line_slice
Base.setindex!(b::Buffer, val, var::Symbol) = :buffer_set_var
Base.setindex!(b::Buffer, val, opt::ByteString) = :buffer_set_option

getnumber(b::Buffer) = :buffer_get_number
getmark(b::Buffer, name::ByteString) = :buffer_get_mark
getname(b::Buffer) = :buffer_get_name
setname!(b::Buffer, name::ByteString) = :buffer_set_name

isvalid(b::Buffer) = :buffer_is_valid
Base.insert!(b::Buffer, lnum::Integer, lines::Vector{ByteString}) = :buffer_insert
