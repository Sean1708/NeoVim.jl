module NeoVim

using Compat
using Docile
import MsgPack
export Nvim, NeoVimError, request, respond

immutable Val{T} end

include("nvim.jl")
include("buffer.jl")
include("window.jl")
include("tabpage.jl")
include("api.jl")

function __init__()
    n, p = Nvim(Val{:Spawn})
    global const API = api_info(n)
    close(n)
    # TODO: do this by sending :q! if possible
    kill(p)

    declare_err(API["error_types"])
    declare_type(API["types"])
    declare_func(API["functions"])
end

immutable NeoVimError <: Exception
    id::Int
    msg::UTF8String
end
@compat NeoVimError(errid, msg::Vector{UInt8}) = NeoVimError(errid, bytestring(msg))
NeoVimError(a::Vector) = NeoVimError(a[1], a[2])

const REQUEST = 0
const RESPONSE = 1
const NOTIFICATION = 2

function request(n::Nvim, func::ByteString, args...)
    requestid = n.reqid
    n.reqid += 1

    MsgPack.pack(n, Any[REQUEST, requestid, func, collect(args)])

    err, res = MsgPack.unpack(n)[3:4]
    if err !== nothing
        throw(NeoVimError(err))
    else
        return sanitize(n, res)
    end
end
function respond(n::Nvim, reqid, args...)
    MsgPack.pack(n, Any[RESPONSE, reqid, nothing, collect(args)])
end
Base.error(n::Nvim, reqid, msg) = MsgPack.pack(n, Any[RESPONSE, reqid, msg, nothing])

function eventloop(nvim::Nvim, data)
    @async while true
        msg = MsgPack.unpack(nvim)
        msgtype = msg[1]
        if msgtype == REQUEST
            reqid = msg[2]
            event = symbol(msg[3])
            args = sanitize(nvim, msg[4])
            # TODO: get logging sorted out
            try
                request_callback(Val{event}, nvim, reqid, args, data)
            catch err
                error(nvim, reqid, string(err))
            end
        elseif msgtype == RESPONSE
            # TODO: make requests asynchronous
        elseif msgtype == NOTIFICATION
            event = symbol(msg[2])
            args = sanitize(nvim, msg[3])
            try
                notification_callback(Val{event}, nvim, args, data)
            end
        else
            throw(NeoVimError(-1, "Unknown message type."))
        end
    end
end

function request_callback(::Any, nvim, reqid, args, data)
    error(nvim, reqid, "Unable to handle event.")
end

function notification_callback(::Any, nvim, args, data)
    throw(NeoVimError(-1, "You must define a notification_callback method."))
end

end # module
