function Add-Numbers {
    param (
        [int]$a,
        [int]$b
    )
    # Breakpoint - Pause here to inspect the state before returning the result
    return $a + $b
}


# function Add-Numbers {
#     param (
#         [int]$a,
#         [int]$b
#     )
#     Wait-Debugger  # Script will pause here until a debugger is attached
#     return $a + $b
# }



# Add-Numbers


# Example usage of the Add-Numbers function
# $sum = Add-Numbers -a 5 -b 10

# Output the result
# Write-Host "The sum of 5 and 10 is: $sum"