# Create a new Crescendo command object
$command = New-CrescendoCommand -Verb Invoke -Noun PsExec -OriginalName "PsExec64.exe"
$command.Description = "Execute commands using PsExec"

# Define parameters
$parameter1 = New-ParameterInfo -Name "ComputerName" -OriginalName "[ComputerName]"
$parameter1.Description = "The target computer."
$parameter1.Position = 1

$parameter2 = New-ParameterInfo -Name "Command" -OriginalName "[Command]"
$parameter2.Description = "The command to execute."
$parameter2.Position = 2

$parameter3 = New-ParameterInfo -Name "Args" -OriginalName "[Args]"
$parameter3.Description = "Arguments for the command."
$parameter3.Position = 3

# Attach parameters to the command
$command.Parameters += $parameter1
$command.Parameters += $parameter2
$command.Parameters += $parameter3

# Add an output handler
$outputHandler = New-OutputHandler -HandlerType "Inline" -StreamOutput $true -Handler '$input | Out-String'
$command.OutputHandlers += $outputHandler

# Export the command
Export-CrescendoCommand -Command $command -TargetDirectory "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Cresendo"
