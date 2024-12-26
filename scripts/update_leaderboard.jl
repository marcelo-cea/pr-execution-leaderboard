using HTTP, JSON, Dates

const GITHUB_TOKEN = ENV["GITHUB_TOKEN"]  # Store your GitHub token as an environment variable
const REPO_OWNER = "Stockless"
const REPO_NAME = "pr-execution-leaderboard"

function fetch_pull_requests()
    url = "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls?state=closed"
    headers = ["Authorization" => "token $GITHUB_TOKEN"]
    response = HTTP.get(url, headers)
    return JSON.parse(String(response.body))
end

function calculate_execution_time(pr)
    created_at = DateTime(pr["created_at"], dateformat"yyyy-mm-ddTHH:MM:SSZ")
    closed_at = DateTime(pr["closed_at"], dateformat"yyyy-mm-ddTHH:MM:SSZ")
    return (closed_at - created_at).value  # Returns execution time in seconds
end

function generate_leaderboard(pr_data)
    times = []
    for pr in pr_data
        if haskey(pr, "merged_at") && !isnothing(pr["merged_at"])
            user = pr["user"]["login"]
            execution_time = calculate_execution_time(pr)
            push!(times, (user, execution_time))
        end
    end
    return sort(times, by = x -> x[2])  # Sort by execution time
end

function write_leaderboard_to_file(leaderboard)
    open("leaderboard.md", "w") do io
        println(io, "# PR Execution Leaderboard\n")
        println(io, "| Rank | Contributor | Execution Time (seconds) |")
        println(io, "|------|-------------|--------------------------|")
        for (rank, (user, time)) in enumerate(leaderboard)
            println(io, "| $rank | $user | $time |")
        end
    end
end

function main()
    pr_data = fetch_pull_requests()
    leaderboard = generate_leaderboard(pr_data)
    write_leaderboard_to_file(leaderboard)
end

main()
