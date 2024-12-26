using BenchmarkTools
using JSON

function my_function_to_benchmark()
    for i in range(0,40,2)
        println("hola")
    end
end

# Benchmark the function
b = @benchmark my_function_to_benchmark()

# Save results to JSON
open("results.json", "w") do f
    JSON.print(f, Dict("benchmark_results" => b))
end
