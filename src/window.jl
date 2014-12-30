@doc doc"""Represents a NeoVim window.""" ->
type Window
    nvim::Nvim
    ext::MsgPack.Ext
end
