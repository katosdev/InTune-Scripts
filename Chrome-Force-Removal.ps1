# Define registry paths for installed programs (32-bit and 64-bit)
$paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
 
# Attempt to find Google Chrome installation
$chrome = $paths | Get-ItemProperty | Where-Object { $_.DisplayName -like "*Google Chrome*" }
 
if ($chrome -ne $null) {
    "Google Chrome is found. Preparing to uninstall..."
    $uninstallString = $chrome.UninstallString
 
    if ($uninstallString -like "*msiexec*") {
        # Handle MSI-based uninstallation
        # Adjust the uninstall string to ensure it runs silently. This often involves replacing '/I' with '/X' and adding '/qn' or '/quiet'.
        $silentUninstallCommand = $uninstallString -replace '/I', '/X' -replace 'MsiExec.exe', 'msiexec.exe' -replace '/I', '/X' `
                                                      # -replace '/F', '/X' -replace ' ', ' ' `
                                                      # -replace '--uninstall', '' `
                                                      # -replace '--', '/' `
                                                      # + ' /qn /quiet /norestart'
        Invoke-Expression $silentUninstallCommand
        "Google Chrome uninstall command has been executed."
    } elseif ($uninstallString -match "\.exe") {
        # Handle direct executable uninstallations
        $exePath, $arguments = $uninstallString -split '(?<=\.exe)', 2
        $silentArguments = $arguments.Trim('"') + ' --uninstall --force-uninstall --multi-install --chrome --system-level'
        Start-Process -FilePath $exePath.Trim('"') -ArgumentList $silentArguments -Wait
        "Google Chrome uninstall command has been executed."
    } else {
        "Uninstall string format is not recognized."
    }
} else {
    "Google Chrome is not found."
}
