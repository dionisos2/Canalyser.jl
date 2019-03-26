using Test

alphabet_lower = "abcdefghijklmnopkrstuvwxyz"

@testset "cipher" begin
    @testset "constructors" begin
        cipher = Cipher("abcdefg", "1234567")
        @test crypt(cipher, "ccddee") == "334455"
        @test crypt(cipher, "123abc123") == "123123123"

        @test decrypt(cipher, "334455") == "ccddee"
        @test decrypt(cipher, "123123123") == "abcabcabc"
        @test decrypt(cipher, "123ufg") == "abcufg"
    end


    @testset "circular modification" begin
        cipher = Cipher(alphabet_lower)
        cipher.offset = 5

        @test crypt(cipher, "aacde") == "ffhij"
        @test decrypt(cipher, "ffhij") == "aacde"

        cipher.offset = 0
        @test crypt(cipher, "abcde") == "abcde"
        @test decrypt(cipher, "abcde") == "abcde"

        cipher.offset = 25
        @test crypt(cipher, "bdef") == "acde"
        @test decrypt(cipher, "acde") == "bdef"

        cipher.offset = -1
        @test crypt(cipher, "bdef") == "acde"
        @test decrypt(cipher, "acde") == "bdef"
    end
end
