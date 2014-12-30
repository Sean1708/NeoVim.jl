using NeoVim
using FactCheck
FactCheck.setstyle(:compact)

facts("Testing sanedict") do
    @fact NeoVim.sanedict(10) => 10

    s = "Here is string!"
    b = convert(Vector{UInt8}, s)
    @fact NeoVim.sanedict(b) => s

    d = [
        Dict{Any,Any}(
            UInt8[0x57, 0x69, 0x6e, 0x64, 0x6f, 0x77] => Dict{Any,Any}(UInt8[0x69, 0x64] => 1),
            UInt8[0x42, 0x75, 0x66, 0x66, 0x65, 0x72] => Dict{Any,Any}(UInt8[0x69, 0x64] => 0),
            UInt8[0x54, 0x61, 0x62, 0x70, 0x61, 0x67, 0x65] => Dict{Any,Any}(UInt8[0x69, 0x64] => 2)
        ),
        Dict{Any,Any}(
            UInt8[0x45, 0x78, 0x63, 0x65, 0x70, 0x74, 0x69, 0x6f, 0x6e] => Dict{Any,Any}(UInt8[0x69, 0x64] => 0),
            UInt8[0x56, 0x61, 0x6c, 0x69, 0x64, 0x61, 0x74, 0x69, 0x6f, 0x6e] => Dict{Any,Any}(UInt8[0x69, 0x64]=>1)
        )
    ]
    saned = [
        Dict{Any,Any}(
            :Buffer => Dict{Any,Any}(:id => 0),
            :Window => Dict{Any,Any}(:id => 1),
            :Tabpage => Dict{Any,Any}(:id => 2)
        ),
        Dict{Any,Any}(
            :Exception => Dict{Any,Any}(:id => 0),
            :Validation => Dict{Any,Any}(:id => 1)
        )
    ]
    @fact NeoVim.sanedict(d) => saned
end

FactCheck.exitstatus()
