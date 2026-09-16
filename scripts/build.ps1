$ErrorActionPreference="Stop"
$root=Get-Location
$work="$root/work"
$out="$root/out"
Remove-Item $work,$out -Recurse -Force -ErrorAction SilentlyContinue
New-Item $work,$out -ItemType Directory|Out-Null

git clone https://github.com/massgravel/Microsoft-Activation-Scripts.git "$work/mas"
git clone https://github.com/massgravel/TSforge.git "$work/tsforge"

dotnet build "$work/tsforge" -c Release

$dll=Get-ChildItem "$work/tsforge" -Recurse -Filter "LibTSforge.dll"|Select-Object -First 1
if(!$dll){throw "LibTSforge.dll not found"}

Copy-Item $dll.FullName "$work/mas/MAS/Separate-Files-Version/Activators/" -Force

$pkg="$out/MAS-build"
New-Item $pkg -ItemType Directory|Out-Null

Copy-Item "$work/mas" "$pkg/mas" -Recurse
Copy-Item "$work/tsforge" "$pkg/tsforge" -Recurse

Remove-Item "$pkg/mas/.git","$pkg/tsforge/.git" -Recurse -Force -ErrorAction SilentlyContinue

New-Item "$pkg/MAS-release" -ItemType Directory|Out-Null

Copy-Item "$work/mas/MAS/All-In-One-Version" "$pkg/MAS-release/All-In-One-Version-KL" -Recurse
Copy-Item "$work/mas/MAS/Separate-Files-Version" "$pkg/MAS-release/Separate-Files-Version" -Recurse

@(
"MAS Automated Build"
""
"Build Time: $(Get-Date -Format o)"
""
"MAS Commit: $(git -C $work/mas rev-parse HEAD)"
"TSforge Commit: $(git -C $work/tsforge rev-parse HEAD)"
".NET: $(dotnet --version)"
) | Out-File "$pkg/BUILDINFO.txt" -Encoding utf8

Copy-Item "$pkg/BUILDINFO.txt" "$root/BUILDINFO.txt"

Compress-Archive "$pkg/*" "$root/MAS-release.zip" -Force
