[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$WorkspacePath
)

$root = [System.IO.Path]::GetFullPath($WorkspacePath)
if (-not [System.IO.Path]::IsPathRooted($root)) {
    throw "WorkspacePath debe ser una ruta absoluta."
}

$folders = @(
    "00_inbox",
    "01_inventory",
    "02_audio",
    "03_transcripts",
    "04_frames",
    "05_summaries",
    "06_index",
    "07_quality",
    "logs"
)

foreach ($folder in $folders) {
    $path = Join-Path $root $folder
    if ($PSCmdlet.ShouldProcess($path, "Crear carpeta local")) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

$manifestPath = Join-Path $root "01_inventory\manifest.csv"
if (-not (Test-Path -LiteralPath $manifestPath)) {
    $header = "id,source_filename,source_sha256,duration_seconds,language,content_type,speaker_count_estimate,status,engine,engine_version,model,parameters,processed_at,notes"
    if ($PSCmdlet.ShouldProcess($manifestPath, "Crear manifest local")) {
        Set-Content -LiteralPath $manifestPath -Value $header -Encoding utf8
    }
}

[PSCustomObject]@{
    workspace = $root
    manifest = $manifestPath
    folders = $folders
    created_or_verified = $true
} | ConvertTo-Json -Depth 3
