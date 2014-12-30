@doc doc"""Represents a NeoVim tabpage.""" ->
type TabPage
    nvim::Nvim
    ext::MsgPack.Ext
end
