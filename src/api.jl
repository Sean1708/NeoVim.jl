#=
 This file declares as much of the Plugin API (as dictated by
 "vim_get_api_info") as possible.
=#

function declare_err(api::Dict)
    # function Base.showerr(io::IO, err::NeoVimError)
    #  if err.id == 0
    #   print(io, "NeoVim ", "Validation", " Error: ", err.msg)
    #  else
    #   print(io, "NeoVim Unknown Error: ", err.msg)
    #  end
    # end
    # pretty much.
    # TODO: This works but I'm fairly sure it can be done much more simply.
    #       Do I need to use Expr(...) in the push! or can I use :(...)?
    ex = Expr(
        :function,
        :(Base.showerror(io::IO, err::NeoVimError))
    )
    currex = ex
    for (id, name) in (Int64,ByteString)[(v[:id], k) for (k, v) in api]
        push!(currex.args, Expr(
            :if,
            :(err.id == $id),
            :(print(io, "NeoVim ", $name, " Error: ", err.msg))
        ))
        currex = currex.args[end]
    end
    push!(currex.args, :(print(io, "NeoVim Unknown Error: ", err.msg)))
    eval(ex)
end

function declare_type(api::Dict)
    # function fromvimtype(n::Nvim, vt::MsgPack.Ext)
    #  if vt.typecode == 0
    #   Buffer(n, vt)
    #  else
    #   error()
    #  end
    # end
    # or words to that effect.
    ex = Expr(
        :function, 
        :(sanitize(n::Nvim, vt::MsgPack.Ext))
    )
    currex = ex
    for (id, typ) in (Int64,Symbol)[(v[:id], k) for (k, v) in api]
        push!(currex.args, Expr(
            :if,
            :(vt.typecode == $id),
            :($(typ)(n, vt))
        ))
        currex = currex.args[end]
    end
    push!(currex.args, :(error("OH MY GOD WHAT HAVE THEY DONE!")))
    eval(ex)
end

function sanitize(n::Nvim, d::Dict)
    Dict{UTF8String,Any}([Symbol(k) => sanitize(n, v) for (k, v) in d])
end
sanitize(n::Nvim, a::Vector) = [sanitize(n, i) for i in a]
sanitize(::Nvim, a::Vector{UInt8}) = bytestring(a)
sanitize(::Nvim, x) = x

api_info(n::Nvim) = request(n, "vim_get_api_info")[2]
