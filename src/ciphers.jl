import Base

using Utils

mutable struct Cipher{T <: AbstractChar}
    map::Dict{T, T}
    inv_map::Dict{T, T}
    offset::Int
    uptodate::Bool
    input_order::Vector{T}
    output::Vector{T}
    input_inv_order::Dict{T, Int}
    function Cipher{T}(map::Dict{T, T}, input_order::Vector{T}, output::Vector{T}) where {T<:AbstractChar}
        tmp = new{T}()
        setfield!(tmp, :map, map)
        setfield!(tmp, :uptodate, false)
        setfield!(tmp, :input_order, input_order)
        setfield!(tmp, :output, output)
        setfield!(tmp, :offset, 0)
        input_inv_order = Dict(Pair(char, index) for (index, char) in enumerate(input_order))
        setfield!(tmp, :input_inv_order, input_inv_order)
        check_validity(tmp)
        return tmp
    end
end


function Cipher(input::T, output::T) where {T<:AbstractString}
    CharType = typeof(input[1])
    map = Dict{CharType, CharType}()
    for (l1, l2) in zip(input, output)
        map[l1] = l2
    end

    return Cipher{CharType}(map, collect(input), collect(output))
end

function Cipher(input::T) where {T<:AbstractString}
    return Cipher(input, input)
end

function crypt(cipher::Cipher{T}, message::String, decrypt = false) where {T <: AbstractChar}
    len = length(cipher.input_order)
    map = Dict{T, T}()
    rotate(char::T, offset::Int) = cipher.input_order[mod(cipher.input_inv_order[char]+offset-1, len)+1]

    if decrypt
        for char in cipher.output
            if haskey(cipher.inv_map, char)
                map[char] = rotate(cipher.inv_map[char], -cipher.offset)
            end
        end
    else
        for char in cipher.input_order
            rchar = rotate(char, cipher.offset)
            if haskey(cipher.map, rchar)
                map[char] = cipher.map[rchar]
            end
        end
    end

    res = Array{T, 1}(undef, length(message))
    for (i, l) in enumerate(message)
        res[i] = get(map, l, l)
    end

    return String(res)
end

function decrypt(cipher::Cipher, message::String)
    return crypt(cipher, message, true)
end

function check_validity(cipher::Cipher)
    map_keys = keys(cipher.map)
    map_values = values(cipher.map)
    if length(unique(map_values)) != length(map_keys)
        error("The mapping should be injectif")
    end
end

function update(cipher::Cipher)
    inv_map = Dict(value=>key for (key, value) in getfield(cipher, :map))
    setfield!(cipher, :inv_map, inv_map)
    setfield!(cipher, :uptodate, true)
end

Base.getproperty(cipher::Cipher, sym::Symbol) = return _getproperty(cipher, Val(sym))
_getproperty(cipher::Cipher, ::Val{sym}) where {sym} = getfield(cipher, sym)

Base.setproperty!(cipher::Cipher, sym::Symbol, value) = _setproperty!(cipher, Val(sym), value)
_setproperty!(cipher::Cipher, ::Val{sym}, value) where {sym} = setfield!(cipher, sym, value)

_setproperty!(cipher::Cipher, ::Val{:uptodate}, value) = error("Cipher.uptodate is a private member")
_setproperty!(cipher::Cipher, ::Val{:inv_map}, value) = error("Cipher.inv_map is a private member")
_setproperty!(cipher::Cipher, ::Val{:map}, value) = error("Cipher.map is a private member")
_setproperty!(cipher::Cipher, ::Val{:input}, value) = error("Cipher.input is a private member")
_setproperty!(cipher::Cipher, ::Val{:input_order}, value) = error("Cipher.input_order is a private member")
_setproperty!(cipher::Cipher, ::Val{:output}, value) = error("Cipher.output is a private member")


function _getproperty(cipher::Cipher, ::Val{:map})
    return readonly_view(getfield(cipher, :map))
end

function _getproperty(cipher::Cipher, ::Val{:inv_map})
    if !cipher.uptodate
        update(cipher)
    end

    return readonly_view(getfield(cipher, :inv_map))
end

