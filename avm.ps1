#!/usr/bin/env pwsh

[CmdletBinding()]
param(
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
  [string[]]$Target
)

Set-StrictMode -Version 3.0

$message = @'
avm: this launcher is no longer supported.

The container/make based AVM toolchain has been replaced by the Avm.Authoring
PowerShell module. Install it from the PowerShell Gallery and run avm from
PowerShell instead:

    Install-PSResource -Name Avm.Authoring -Scope CurrentUser -TrustRepository
    Import-Module Avm.Authoring
    avm --help

See https://github.com/Azure/azure-verified-modules-tools for details.
'@

[Console]::Error.WriteLine($message)
exit 1
