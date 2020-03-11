﻿$ErrorActionPreference = 'Stop';
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32      = 'https://download.microsoft.com/download/A/E/7/AE709F7E-37F5-473F-A615-42D6F66AE32F/MMASetup-i386.exe'
$checksum32 = '2986B39E819E2C16F524DB2AF318779E0E8EAC72819592227090C1BB4C8381CE'
$url64      = 'https://download.microsoft.com/download/6/f/a/6fa8f46c-1f02-4654-a535-a315b35a76cb/MMASetup-AMD64.exe'
$checksum64 = 'DB1CC508344481EC94884C17A8B39EF0E1E56E3E3E7E8E482079F6C66768908D'

# package parameters
$pp = Get-PackageParameters

if ($pp['WorkspaceId'] -and $pp['WorkspaceKey']) {
  $azureArgs = "ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=$($pp['WorkspaceId']) OPINSIGHTS_WORKSPACE_KEY=$($pp['WorkspaceKey'])"
  Write-Verbose "Configuring with Azure Monitor workspace"
} elseif ($pp['WorkspaceId'] -or $pp['WorkspaceKey']) {
  throw "Both WorkspaceId and WorkspaceKey package parameters must be supplied"
} else {
  Write-Host "Installing agent, but configuration will need to be done via Control Panel app"
}

if ($pp['ProxyURL']) {
  $azureArgs += "OPINSIGHTS_PROXY_URL=$($pp['ProxyURL'])"
}

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Microsoft Monitoring Agent'
  fileType      = 'exe'

  # https://github.com/MicrosoftDocs/azure-docs/issues/29171
  # https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows#install-the-agent-using-the-command-line
  silentArgs    = "/C:`"setup.exe /qn NOAPM=1 $azureArgs AcceptEndUserLicenseAgreement=1`""
  
  validExitCodes= @(0) #please insert other valid exit codes here
  url           = $url32
  checksum      = $checksum32
  checksumType  = 'sha256'
  url64bit      = $url64
  checksum64    = $checksum64
  checksumType64= 'sha256'
  destination   = $toolsDir
}

Install-ChocolateyPackage @packageArgs
