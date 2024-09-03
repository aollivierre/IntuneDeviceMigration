# function Log-Message {
#     param (
#         [string]$Message,
#         [string]$Level = "INFO"
#     )

#     Write-Log -Message $Message -Level $Level
# }


# function Write-Log {
#     param (
#         [string]$Message,
#         [string]$Level
#     )
#     # Original implementation that you don't want to run in the test
#     Write-Host "[$Level] $Message"
# }