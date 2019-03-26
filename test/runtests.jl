using Test
using Canalyser


tests = ["cipher_test.jl"]

for test in tests
  include(test)
end
