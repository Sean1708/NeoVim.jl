@doc """
    Nvim([address,] port)
    Nvim(path)

Represents a particular NeoVim instance. Can be instantiated with any method
signature which would return a `TCPSocket` or `Pipe` when passed to `connect`.
""" ->
type Nvim{T <: Union(Base.TCPSocket, Base.Pipe)}
    conn::T
end

function Nvim(args...)
    n = Nvim(connect(args...))
    finalizer(n, close)
    return n
end

Base.close(n::Nvim) = close(n.conn)

function getindex(n::Nvim, name::Symbol)
    if name === :buffers
        return :vim_get_buffers
    elseif name === :windows
        return :vim_get_windows
    elseif name === :tabpages
        return :vim_get_tabpages
    else
        throw(KeyError(name))
    end
end

MsgPack.pack(n::Nvim, v) = MsgPack.pack(n.conn, v)
MsgPack.unpack(n::Nvim) = MsgPack.unpack(n.conn)
