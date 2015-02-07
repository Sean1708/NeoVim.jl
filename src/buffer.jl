@doc doc"""Represents a NeoVim buffer.""" ->
type Buffer
    nvim::Nvim
    data::MsgPack.Ext
end

# TODO: using these in a for-loop does not guarantee that every line will be
# iterated over as buffer length could change in the for-loop
Base.length(b::Buffer) = buffer_line_count(b)
Base.endof(b::Buffer) = length(b)

function Base.getindex(b::Buffer, idx::Integer)
    # TODO: use 0.4 syntax
    idx = convert(Int, idx)
    if idx == 0
        throw(BoundsError())
    elseif idx < 0
        buffer_get_line(b, idx)
    else
        buffer_get_line(b, idx-1)
    end
end
function Base.getindex(b::Buffer, rng::UnitRange)
    buffer_get_line_slice(b, rng.start-1, rng.stop-1, true, true)
end
Base.getindex(b::Buffer, rng::StepRange) = [b[i] for i in rng]
# TODO: rethink this API (and use 0.4 syntax)
Base.getindex(b::Buffer, opt::Symbol) = buffer_get_option(b, string(opt))
Base.getindex(b::Buffer, var::ByteString) = buffer_get_var(b, var)

Base.setindex!(b::Buffer, val, idx::Integer) = buffer_set_line(b, idx, val)
function Base.setindex!(b::Buffer, val, rng::UnitRange)
    buffer_set_line_slice(b, rng.start-1, rng.stop-1, true, true, val)
end
function Base.setindex!(b::Buffer, val, rng::StepRange)
    for (i, v) in zip(rng, val)
        b[i] = v
    end
end
Base.setindex!(b::Buffer, val, opt::Symbol) = buffer_set_option(b, string(opt), val)
Base.setindex!(b::Buffer, val, var::ByteString) = buffer_set_var(b, var, val)

Base.insert!(b::Buffer, lnum, lines) = buffer_insert(b, lnum, lines)
