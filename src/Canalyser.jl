module Canalyser

export cc, Cipher, crypt, decrypt

include("ciphers.jl")

function cc()
    mapping = Dict('a'=>'b', 'b'=>'c')
    cipher = Cipher(mapping)

    println("s2")
    println(crypt(cipher, "abcdefghaaaaabbbbcccc"))
    println("e2")
end


end # module
