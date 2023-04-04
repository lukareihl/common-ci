
param(
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [string]$ProjectDir = ".",
    [string]$Name = "Release_x64",
    [string]$Configuration = "Release",
    [string]$Arch = "x64"
)

$RepoPath = [IO.Path]::Combine($pwd, $RepoName)

Write-Output "Entering '$RepoPath'"
Push-Location $RepoPath

try {

    Write-Output "Testing $($Options.Name)"
    
    dotnet test $ProjectDir --no-build --no-restore --results-directory "test-results/integration/$Name" --filter "FullyQualifiedName~Integration|TestCategory=Integration" --blame-crash -l "trx" -c $Configuration -a $Arch

}
finally {

    Write-Output "Leaving '$RepoPath'"
    Pop-Location

}

exit $LASTEXITCODE
