@doc doc"""
    Nvim([address,] port)
    Nvim(path)

Represents a particular NeoVim instance. Can be instantiated with any method
signature which would return a `TCPSocket` or `Pipe` when passed to `connect`.
""" ->
type Nvim{T}
    recstream::T
    sendstream::T

    reqid::Int
end

function Nvim{T <: Base.AsyncStream}(ins::T, outs::T)
    n = Nvim(ins, outs, 1)
    finalizer(n, close)
    n
end

function Nvim(::Type{Val{:Embedded}})
    ins, outs = STDIN, STDOUT

    # TODO: use proper logging (Logging.jl, LumberJack.jl) and a more correct file path
    logfile = open(joinpath(homedir(), ".neovim.jl.log"), "a")
    redirect_stdout(logfile)
    redirect_stderr(logfile)
    redirect_stdin()
    # use now() when 0.4 is ubiquitous
    #println("Log starting $(now())\n===")
    println("Starting Log\n============")

    Nvim(ins, outs)
end

function Nvim(::Type{Val{:Spawn}})
    # TODO: have a way to allow users to specify program path
    ins, outs, proc = readandwrite(`nvim --embed`)
    Nvim(ins, outs), proc
end

# TODO: would it be better to split this up?
function Nvim(args...)
    conn = connect(args...)
    Nvim(conn, conn)
end

function Base.close(n::Nvim)
    close(n.recstream)
    close(n.sendstream)
end

function getindex(n::Nvim, name::Symbol)
    if name === :buffers
        return vim_get_buffers(n)
    elseif name === :windows
        return vim_get_windows(n)
    elseif name === :tabpages
        return vim_get_tabpages(n)
    else
        throw(KeyError(name))
    end
end

MsgPack.pack(n::Nvim, v) = MsgPack.pack(n.sendstream, v)
MsgPack.unpack(n::Nvim) = MsgPack.unpack(n.recstream)
