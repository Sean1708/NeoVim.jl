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
    for (id, name) in (Int64,ByteString)[(v["id"], k) for (k, v) in api]
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
    # function sanitize(n::Nvim, vt::MsgPack.Ext)
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
    for (id, typ) in (Int64,Symbol)[(v["id"], k) for (k, v) in api]
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
    Dict{UTF8String,Any}([bytestring(k) => sanitize(n, v) for (k, v) in d])
end
sanitize(n::Nvim, a::Vector) = [sanitize(n, i) for i in a]
sanitize(::Nvim, a::Vector{UInt8}) = bytestring(a)
sanitize(::Nvim, x) = x

api_info(n::Nvim) = request(n, "vim_get_api_info")[2]

function vimtojulia(s)
    if s == "Nil"
        return :Void
    elseif s == "Boolean"
        return :Bool
    elseif s == "Integer"
        return :Int64
    elseif s == "Float"
        return :Float64
    elseif s == "String"
        return :UTF8String
    elseif s == "Array"
        return :Vector
    elseif s == "Dictionary"
        return :Dict
    else
        return :Any
    end
end

function declare_func(api::Vector)
    for d in api
        vimnm = d["name"]
        typenm = split(vimnm, '_', keep=false)
        typenm, funcnm = typenm[1], join(typenm[2:end], "_")
        funcnm == "eval" && (funcnm = "vimeval")

        args = (Symbol, Symbol)[]
        for (typ, nam) in d["parameters"]
            nam == "end" && (nam = "finish")
            push!(args, (nam, vimtojulia(typ)))
        end

        if typenm == "vim"
            typenm = "nvim"
        else
            shift!(args)
        end
        unshift!(args, (typenm, ucfirst(typenm)))

        eval(Expr(
            :function,
            Expr(:call, symbol(funcnm), [:($nm::$tnm) for (nm, tnm) in args]...),
            Expr(
                :call,
                :request,
                if args[1][2] == :Nvim
                    args[1][1]
                else
                    :($(args[1][1]).nvim)
                end,
                vimnm,
                (if args[1][2] == :Nvim
                    [nm for (nm, _) in args[2:end]]
                else
                    cont = shift!(args)[1]
                    vcat(:($(cont).data), [nm for (nm, _) in args])
                end)...
            )
        ))
    end
end
