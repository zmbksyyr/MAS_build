$ErrorActionPreference="Stop"

$root=Get-Location
$work="$root/work"
$out="$root/out"

Remove-Item $work,$out -Recurse -Force -ErrorAction SilentlyContinue
New-Item $work,$out -ItemType Directory | Out-Null

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

Write-Host "Find MAS paths"

$aio=Get-ChildItem "$work/mas" -Directory -Recurse -Filter "All-In-One-Version-KL" | Select-Object -First 1

$separate=Get-ChildItem "$work/mas" -Directory -Recurse -Filter "Separate-Files-Version" | Select-Object -First 1

$activator=Get-ChildItem "$work/mas" -Directory -Recurse -Filter "Activators" | Select-Object -First 1


if(!$aio){
    throw "All-In-One-Version-KL not found"
}

if(!$separate){
    throw "Separate-Files-Version not found"
}

if(!$activator){
    throw "Activators directory not found"
}

Write-Host "Inject DLL"

Copy-Item $dll.FullName $activator.FullName -Force


Write-Host "Create package"

$pkg="$out/MAS-build"

New-Item $pkg -ItemType Directory | Out-Null


Copy-Item "$work/mas" "$pkg/mas" -Recurse -Force
Copy-Item "$work/tsforge" "$pkg/tsforge" -Recurse -Force


Remove-Item "$pkg/mas/.git" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$pkg/tsforge/.git" -Recurse -Force -ErrorAction SilentlyContinue


New-Item "$pkg/MAS-release" -ItemType Directory | Out-Null


Copy-Item `
$aio.FullName `
"$pkg/MAS-release/All-In-One-Version-KL" `
-Recurse `
-Force


Copy-Item `
$separate.FullName `
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
"LibTSforge: $($dll.FullName)"
) | Out-File "$pkg/BUILDINFO.txt" -Encoding utf8


Copy-Item "$pkg/BUILDINFO.txt" "$root/BUILDINFO.txt" -Force


Write-Host "Create ZIP"

Compress-Archive `
"$pkg/*" `
"$root/MAS-release.zip" `
-Force


Write-Host "Build complete"
