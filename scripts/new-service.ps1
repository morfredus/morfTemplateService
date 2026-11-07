<#
    new-service.ps1 - Amorce un nouveau service morfSystem a partir de ce gabarit.

    Copie tout le projet dans un nouveau dossier en remplacant les noms :
        morfTemplateService  -> <NomCamel>   (projet / bibliotheque / cible CMake)
        morftemplate         -> <nom>        (namespace, include, binaire, config)
        MORFTEMPLATE         -> <NOM>        (prefixe de macro)

    Le projet genere ne garde AUCUNE trace du gabarit (meme comportement que
    new-service.sh) : fichiers du gabarit supprimes, README / CHANGELOG / VERSION
    repartis de zero (scripts\skeleton), controle final des restes.

    Usage :
        powershell -ExecutionPolicy Bypass -File scripts\new-service.ps1 <nom> <NomCamel> [dest]
    Exemple :
        ... new-service.ps1 morfwatch morfWatch
          -> cree ..\morfWatch_travail
#>
param(
    [Parameter(Mandatory=$true)][string]$Lower,
    [Parameter(Mandatory=$true)][string]$Camel,
    [string]$Dest = ""
)
$ErrorActionPreference = "Stop"
$Upper = $Lower.ToUpper()

$root = Split-Path -Parent $PSScriptRoot
if (-not $Dest) { $Dest = Join-Path (Split-Path -Parent $root) "${Camel}_travail" }
if (Test-Path $Dest) { throw "Destination deja existante : $Dest" }

Write-Host "Gabarit : $root"
Write-Host "Nouveau : $Dest  ($Camel / $Lower / $Upper)"

# UTF-8 sans BOM et LF, comme le reste du parc.
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Write-Lf($path, $text) {
    [System.IO.File]::WriteAllText($path, ($text -replace "`r`n", "`n"), $utf8)
}

# --- 1. Copier l'arbre (sans .git ni build) ------------------------------
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Get-ChildItem -Path $root -Force | Where-Object {
    $_.Name -notin @('.git','build') -and $_.Name -notlike 'build-*'
} | Copy-Item -Destination $Dest -Recurse -Force

# --- 2. Retirer ce qui ne concerne que le gabarit, poser les docs du projet
# Les squelettes remplacent README, CHANGELOG et index de docs ; scripts de
# clonage, roadmap, contribution et guide d'integration decrivent le gabarit.
$skel = Join-Path $Dest "scripts\skeleton"
Copy-Item "$skel\README.md"         "$Dest\README.md" -Force
Copy-Item "$skel\README.fr.md"      "$Dest\README.fr.md" -Force
Copy-Item "$skel\CHANGELOG.md"      "$Dest\CHANGELOG.md" -Force
Copy-Item "$skel\docs-fr-README.md" "$Dest\docs\fr\README.md" -Force
Copy-Item "$skel\docs-en-README.md" "$Dest\docs\en\README.md" -Force
Remove-Item -Recurse -Force $skel, "$Dest\scripts\new-service.sh", "$Dest\scripts\new-service.ps1", `
    "$Dest\ROADMAP.md", "$Dest\CONTRIBUTING.md", "$Dest\docs\fr\INTEGRATION.md"
Write-Lf "$Dest\VERSION" "0.1.0`n"

# Plus de drapeau de gabarit dans service.json (il ferait sauter le service a
# l'installation) ; type " service " dans morfproject.json.
$sj = (Get-Content -LiteralPath "$Dest\service.json" -Raw) -split "`r?`n" |
    Where-Object { $_ -notmatch '"_comment_template"|"template": true' }
Write-Lf "$Dest\service.json" ($sj -join "`n")
$mp = (Get-Content -LiteralPath "$Dest\morfproject.json" -Raw) -replace '"type": "template"', '"type": "service"'
Write-Lf "$Dest\morfproject.json" $mp

# --- 3. Remplacer les jetons dans les fichiers texte (hors third_party) --
$today = Get-Date -Format "yyyy-MM-dd"
$year  = Get-Date -Format "yyyy"
Get-ChildItem -Path $Dest -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\third_party\\morf\\beacon\\'   # ne pas toucher au code vendore
} | ForEach-Object {
    try {
        $c = [System.IO.File]::ReadAllText($_.FullName)
    } catch { return }
    if ($c -match 'morfTemplateService|morftemplate|MORFTEMPLATE|@DATE@|@YEAR@') {
        $c = $c -creplace 'morfTemplateService', $Camel `
                -creplace 'morftemplate',        $Lower `
                -creplace 'MORFTEMPLATE',         $Upper `
                -creplace '@DATE@',               $today `
                -creplace '@YEAR@',               $year
        [System.IO.File]::WriteAllText($_.FullName, $c, $utf8)
    }
}

# --- 4. Renommer fichiers/dossiers portant l'ancien nom ------------------
Rename-Item "$Dest\include\morftemplate"               $Lower
Rename-Item "$Dest\config\morftemplate.example.json"   "$Lower.example.json"
Rename-Item "$Dest\scripts\linux\morftemplate.service" "$Lower.service"

# --- 5. Controle : aucune trace du gabarit ne doit subsister --------------
# Simple avertissement (un nom de projet peut contenir " template ").
$left = Get-ChildItem -Path $Dest -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\(third_party|\.github)\\'
} | Select-String -Pattern 'template|gabarit' -List
if ($left) {
    Write-Warning "Traces du gabarit restantes dans le projet genere :"
    $left | ForEach-Object { Write-Warning "  $($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
}

Write-Host "Termine."
Write-Host "  cd `"$Dest`""
Write-Host "  cmake --preset mingw ; cmake --build --preset mingw"
Write-Host "  puis coder le metier dans src\ExampleModule.* et adapter ModuleFactory / CMakeLists."
Write-Host ""
Write-Host "AVANT TOUT DEPLOIEMENT : attribuer un port."
Write-Host "  Le projet genere porte le port provisoire 8901, jamais utilise en"
Write-Host "  production. Deux endroits le portent : config\$Lower.example.json"
Write-Host "  et le defaut compile dans include\$Lower\ServiceConfig.h."
Write-Host "  1. Reserver un port libre du bloc 8787-8799 dans 'ports.allocations'"
Write-Host "     de morfTools\ecosystem.json (y ajouter aussi ce projet)."
Write-Host "  2. Le reporter dans les DEUX emplacements ci-dessus."
Write-Host "  3. Verifier avec : morfTools\doctor.ps1"
Write-Host "  'morf doctor' echoue tant que le registre et la configuration divergent."
