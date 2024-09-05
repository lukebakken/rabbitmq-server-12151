$ProgressPreference = 'Continue'
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

New-Variable -Name curdir -Option Constant `
  -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)

Write-Host "[INFO] script directory: $curdir"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 'Tls12'

New-Variable -Name rabbitmq_version -Option Constant -Value '3.13.7'

$rabbitmq_dir = Join-Path -Path $curdir -ChildPath "rabbitmq_server-$rabbitmq_version"
$rabbitmq_sbin = Join-Path -Path $rabbitmq_dir -ChildPath 'sbin'
$rabbitmq_download_url = "https://github.com/rabbitmq/rabbitmq-server/releases/download/v$rabbitmq_version/rabbitmq-server-windows-$rabbitmq_version.zip"
$rabbitmq_zip_file = Join-Path -Path $curdir -ChildPath "rabbitmq-server-windows-$rabbitmq_version.zip"
$rabbitmq_plugins_cmd = Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmq-plugins.bat'
$rabbitmq_server_cmd = Join-Path -Path $rabbitmq_sbin -ChildPath 'rabbitmq-server.bat'

$rabbitmq_base = $curdir
$rabbitmq_conf = Join-Path -Path $rabbitmq_base -ChildPath 'rabbitmq.conf'
$rabbitmq_env_conf = Join-Path -Path $rabbitmq_base -ChildPath 'rabbitmq-env-conf.bat'

# $env:LOG = 'debug'
try
{
    $env:RABBITMQ_BASE = $rabbitmq_base
    $env:RABBITMQ_ALLOW_INPUT = 'true'
    $env:RABBITMQ_CONFIG_FILE = $rabbitmq_conf
    $env:RABBITMQ_CONF_ENV_FILE = $rabbitmq_env_conf

    if (!(Test-Path -Path $rabbitmq_dir))
    {
        Invoke-WebRequest -Verbose -UseBasicParsing -Uri $rabbitmq_download_url -OutFile $rabbitmq_zip_file
        Expand-Archive -Path $rabbitmq_zip_file -DestinationPath $curdir
        # & $rabbitmq_plugins_cmd enable rabbitmq_management
    }

    & $rabbitmq_server_cmd
}
finally
{
    Remove-Item -Verbose -Force -ErrorAction Continue env:\LOG
    Remove-Item -Verbose -Force -ErrorAction Continue env:\RABBITMQ_BASE
    Remove-Item -Verbose -Force -ErrorAction Continue env:\RABBITMQ_ALLOW_INPUT
    Remove-Item -Verbose -Force -ErrorAction Continue env:\RABBITMQ_CONFIG_FILE
    Remove-Item -Verbose -Force -ErrorAction Continue env:\RABBITMQ_CONF_ENV_FILE
}
