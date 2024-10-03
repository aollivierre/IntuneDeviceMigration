# # Use Get-Credential to prompt for GitHub PAT (you can ignore the username)
# $credential = Get-Credential -Message "Please enter your GitHub Personal Access Token (PAT). You can leave the username field empty."

# # Extract the SecureString from the credential object
# $SecurePAT = $credential.Password

# # Convert the SecureString to plain text if needed (for demonstration purposes, not recommended in production)
# $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
# $plainTextPAT = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

# # Use the PAT (in plain text or secure form as needed)
# Write-Host "Secure PAT has been collected."






# # Load necessary assemblies
# Add-Type -AssemblyName System.Windows.Forms
# Add-Type -AssemblyName System.Drawing

# # Create a new form
# $form = New-Object system.windows.forms.Form
# $form.Text = "GitHub PAT Input"
# $form.Size = New-Object System.Drawing.Size(300,150)
# $form.StartPosition = "CenterScreen"

# # Create a label for instructions
# $label = New-Object system.windows.forms.Label
# $label.Text = "Enter your GitHub Personal Access Token (PAT):"
# $label.AutoSize = $true
# $label.Location = New-Object System.Drawing.Point(10,10)
# $form.Controls.Add($label)

# # Create a textbox for the PAT input, with masking (password char)
# $textbox = New-Object system.windows.forms.TextBox
# $textbox.Size = New-Object System.Drawing.Size(260,20)
# $textbox.Location = New-Object System.Drawing.Point(10,40)
# $textbox.UseSystemPasswordChar = $true # Mask input
# $form.Controls.Add($textbox)

# # Create an OK button
# $okButton = New-Object system.windows.forms.Button
# $okButton.Text = "OK"
# $okButton.Location = New-Object System.Drawing.Point(190,70)
# $okButton.Add_Click({
#     $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
#     $form.Close()
# })
# $form.Controls.Add($okButton)

# # Create a Cancel button
# $cancelButton = New-Object system.windows.forms.Button
# $cancelButton.Text = "Cancel"
# $cancelButton.Location = New-Object System.Drawing.Point(100,70)
# $cancelButton.Add_Click({
#     $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
#     $form.Close()
# })
# $form.Controls.Add($cancelButton)

# # Show the form
# $form.Topmost = $true
# $result = $form.ShowDialog()

# # Handle the result
# if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
#     # Convert the text input to a SecureString
#     $SecurePAT = ConvertTo-SecureString $textbox.Text -AsPlainText -Force
#     Write-Host "PAT securely captured."
# } else {
#     Write-Host "Operation canceled."
# }




# Prompt the user to enter the PAT securely using PSReadLine's masking
# if ($Host.Name -eq "ConsoleHost" -and (Get-Command -Name Read-Host -ParameterName AsSecureString -ErrorAction SilentlyContinue)) {
#     $SecurePAT = Read-Host -AsSecureString "Enter your GitHub Personal Access Token (PAT)"
# } else {
#     Write-Host "PSReadLine is not available for secure input."
# }



# # Function to securely collect a secret without displaying anything in the console
# function Read-Secret {
#     $secret = ""
#     $key = $null

#     # Read input one character at a time
#     while ($key -ne 'Enter') {
#         $key = [System.Console]::ReadKey($true)
#         if ($key.Key -ne 'Enter') {
#             $secret += $key.KeyChar
#         }
#     }

#     # Convert the secret to SecureString
#     $SecureSecret = ConvertTo-SecureString $secret -AsPlainText -Force
#     return $SecureSecret
# }

# # Prompt for the secret
# Write-Host "Please enter your GitHub Personal Access Token (PAT):"
# $SecurePAT = Read-Secret

# # Now you have the PAT as a SecureString
# Write-Host "Secure PAT has been collected."







# # Load necessary assemblies for Windows Forms
# Add-Type -AssemblyName System.Windows.Forms
# Add-Type -AssemblyName System.Drawing

# # Create a new form
# $form = New-Object system.windows.forms.Form
# $form.Text = "GitHub PAT Input"
# $form.Size = New-Object System.Drawing.Size(350,150)
# $form.StartPosition = "CenterScreen"

# # Create a label for instructions
# $label = New-Object system.windows.forms.Label
# $label.Text = "Enter your GitHub Personal Access Token (PAT):"
# $label.AutoSize = $true
# $label.Location = New-Object System.Drawing.Point(10,10)
# $form.Controls.Add($label)

# # Create a textbox for the PAT input, with masking (password char)
# $textbox = New-Object system.windows.forms.TextBox
# $textbox.Size = New-Object System.Drawing.Size(300,20)
# $textbox.Location = New-Object System.Drawing.Point(10,40)
# $textbox.UseSystemPasswordChar = $true # Mask input
# $form.Controls.Add($textbox)

# # Create an OK button
# $okButton = New-Object system.windows.forms.Button
# $okButton.Text = "OK"
# $okButton.Location = New-Object System.Drawing.Point(190,70)
# $okButton.Add_Click({
#     $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
#     $form.Close()
# })
# $form.Controls.Add($okButton)

# # Create a Cancel button
# $cancelButton = New-Object system.windows.forms.Button
# $cancelButton.Text = "Cancel"
# $cancelButton.Location = New-Object System.Drawing.Point(100,70)
# $cancelButton.Add_Click({
#     $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
#     $form.Close()
# })
# $form.Controls.Add($cancelButton)

# # Show the form
# $form.Topmost = $true
# $result = $form.ShowDialog()

# # Handle the result
# if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
#     # Convert the text input to a SecureString
#     $SecurePAT = ConvertTo-SecureString $textbox.Text -AsPlainText -Force
#     Write-Host "PAT securely captured."
# } else {
#     Write-Host "Operation canceled."
# }









$SecurePAT = Get-GitHubPAT

if ($SecurePAT -ne $null) {
    # Continue with the secure PAT
    Write-Host "Using the captured PAT..."
    # Further logic here
} else {
    Write-Host "No PAT was captured."
}
