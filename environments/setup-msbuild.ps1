
Invoke-WebRequest -Uri https://github.com/microsoft/vswhere/releases/download/3.1.1/vswhere.exe -OutFile vswhere.exe
$MsBuild = .\vswhere.exe -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1
$MsBuildPath = $(Get-ChildItem $MsBuild).Directory.FullName
Write-Output "Found msbuild in '$MsBuildPath'"
Write-Output $MsBuildPath | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append