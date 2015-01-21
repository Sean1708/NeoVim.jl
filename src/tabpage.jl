@doc doc"""Represents a NeoVim tabpage.""" ->
type Tabpage
    nvim::Nvim
    ext::MsgPack.Ext
end
