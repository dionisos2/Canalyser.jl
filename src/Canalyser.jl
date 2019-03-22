module Canalyser

export cc

include("ciphers.jl")

using .Ciphers

function cc()
    mapping = Dict("a"=>"b", "b"=>"c")
    cipher = Cipher(mapping)

    println("s2")
    println(crypt(cipher, "abcdefghaaaaabbbbcccc"))
    println("e2")
end


end # module
