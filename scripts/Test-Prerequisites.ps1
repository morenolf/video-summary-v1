[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$WorkspacePath,

    [string]$FfmpegCommand = "ffmpeg",

    [string]$WhisperCommand = "whisper-cli",

    [int]$MinimumFreeSpaceGb = 30
)

function Get-CommandCheck {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$VersionArgument
    )

    $resolved = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $resolved) {
        return [PSCustomObject]@{
            name = $Name
            available = $false
            path = $null
            version = $null
        }
    }

    $version = $null
    try {
        $version = (& $resolved.Source $VersionArgument 2>&1 | Select-Object -First 1 | Out-String).Trim()
    } catch {
        $version = "No se pudo consultar: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        name = $Name
        available = $true
        path = $resolved.Source
        version = $version
    }
}

$workspaceExists = Test-Path -LiteralPath $WorkspacePath -PathType Container
$driveName = [System.IO.Path]::GetPathRoot([System.IO.Path]::GetFullPath($WorkspacePath)).TrimEnd(':','\')
$drive = Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue
$freeSpaceGb = if ($drive) { [Math]::Round($drive.Free / 1GB, 2) } else { $null }

$ffmpeg = Get-CommandCheck -Name $FfmpegCommand -VersionArgument "-version"
$whisper = Get-CommandCheck -Name $WhisperCommand -VersionArgument "--help"
$nvidiaSmi = Get-CommandCheck -Name "nvidia-smi" -VersionArgument "--query-gpu=name,memory.total,driver_version --format=csv,noheader"

$ready = $workspaceExists -and
    $ffmpeg.available -and
    $whisper.available -and
    $null -ne $freeSpaceGb -and
    $freeSpaceGb -ge $MinimumFreeSpaceGb

$report = [PSCustomObject]@{
    ready_for_smoke_test = $ready
    workspace = [PSCustomObject]@{
        path = [System.IO.Path]::GetFullPath($WorkspacePath)
        exists = $workspaceExists
        free_space_gb = $freeSpaceGb
        minimum_free_space_gb = $MinimumFreeSpaceGb
    }
    ffmpeg = $ffmpeg
    whisper = $whisper
    gpu = $nvidiaSmi
    next_step = if ($ready) {
        "Ejecutar sólo la prueba de humo del checklist; no procesar un lote."
    } else {
        "Instalar o configurar únicamente los requisitos faltantes y volver a ejecutar este chequeo."
    }
}

$report | ConvertTo-Json -Depth 5
if (-not $ready) {
    exit 1
}
