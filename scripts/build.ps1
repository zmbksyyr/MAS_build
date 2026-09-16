$ErrorActionPreference="Stop"

$root=Get-Location
$work="$root/work"
$out="$root/out"

Remove-Item $work,$out -Recurse -Force -ErrorAction SilentlyContinue

New-Item $work -ItemType Directory | Out-Null
New-Item $out -ItemType Directory | Out-Null

Write-Host "Clone MAS"

git clone https://github.com/massgravel/Microsoft-Activation-Scripts.git "$work/mas"

Write-Host "Clone TSforge"

git clone https://github.com/massgravel/TSforge.git "$work/tsforge"

Write-Host "Build TSforge"

dotnet build "$work/tsforge" -c Release

Write-Host "Find LibTSforge.dll"

$dll=Get-ChildItem "$work/tsforge" -Recurse -Filter "LibTSforge.dll" | Select-Object -First 1

if(!$dll){
    throw "LibTSforge.dll not found"
}

Write-Host "Inject DLL"

$activator="$work/mas/Separate-Files-Version/Activators"

if(!(Test-Path $activator)){
    $activator="$work/mas/MAS/Separate-Files-Version/Activators"
}

if(!(Test-Path $activator)){
    throw "MAS Activators directory not found"
}

Copy-Item $dll.FullName $activator -Force

Write-Host "Prepare package"

$pkg="$out/MAS-build"

New-Item $pkg -ItemType Directory | Out-Null

Copy-Item "$work/mas" "$pkg/mas" -Recurse -Force
Copy-Item "$work/tsforge" "$pkg/tsforge" -Recurse -Force

Remove-Item "$pkg/mas/.git" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$pkg/tsforge/.git" -Recurse -Force -ErrorAction SilentlyContinue

New-Item "$pkg/MAS-release" -ItemType Directory | Out-Null

Write-Host "Locate MAS release folders"

$masRoot="$work/mas"

if(Test-Path "$masRoot/MAS"){
    $masRoot="$masRoot/MAS"
}

if(!(Test-Path "$masRoot/All-In-One-Version")){
    throw "All-In-One-Version not found"
}

if(!(Test-Path "$masRoot/Separate-Files-Version")){
    throw "Separate-Files-Version not found"
}

Copy-Item `
"$masRoot/All-In-One-Version" `
"$pkg/MAS-release/All-In-One-Version-KL" `
-Recurse `
-Force

Copy-Item `
"$masRoot/Separate-Files-Version" `
"$pkg/MAS-release/Separate-Files-Version" `
-Recurse `
-Force


Write-Host "Generate BUILDINFO"

@(
"MAS Automated Build"
""
"Build Time: $(Get-Date -Format o)"
""
"MAS Commit: $(git -C $work/mas rev-parse HEAD)"
"TSforge Commit: $(git -C $work/tsforge rev-parse HEAD)"
".NET: $(dotnet --version)"
"LibTSforge.dll: $($dll.FullName)"
) | Out-File "$pkg/BUILDINFO.txt" -Encoding utf8


Copy-Item "$pkg/BUILDINFO.txt" "$root/BUILDINFO.txt" -Force


Write-Host "Create release zip"

Compress-Archive `
"$pkg/*" `
"$root/MAS-release.zip" `
-Force


Write-Host "Build completed"
