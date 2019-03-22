module Ciphers

export Cipher, crypt, decrypt

mutable struct Cipher{T <: AbstractString}
    map::Dict{T, T}
    inv_map::Dict{T, T}
    uptodate::Bool
    function Cipher{T}(map::Dict{T, T}) where {T<:AbstractString}
        tmp = new{T}()
        tmp.map = map
        tmp.uptodate = false
        return tmp
    end
end


function Cipher(map::Dict{T, T}) where {T<:AbstractString}
    return Cipher{T}(map)
end

function crypt(cipher::Cipher, message::String)
    res = ""
    for l in message
        l = string(l)
        if haskey(cipher.map, l)
            res *= cipher.map[l]
        else
            res *= l*"7"
        end
    end
    return res
end

function decrypt(cipher::Cipher, message::String)
    return false
end


end
