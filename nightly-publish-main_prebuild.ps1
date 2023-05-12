
param (
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    [Parameter(Mandatory=$true)]
    $Options
)

. ./constants.ps1

# This token is used by the hub command.
Write-Output "Setting GITHUB_TOKEN"
$env:GITHUB_TOKEN="$GitHubToken"

Write-Output "::group::Configure Git"
./steps/configure-git.ps1 -GitHubToken $GitHubToken
Write-Output "::endgroup::"

Write-Output "::group::Clone $RepoName"
./steps/clone-repo.ps1 -RepoName $RepoName
Write-Output "::endgroup::"

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Output "::group::Fetch Assets"
./steps/run-repo-script.ps1 -RepoName $RepoName -ScriptName "fetch-assets.ps1" -Options $Options.Keys
Write-Output "::endgroup::"

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Output "::group::Setup Environment"
./steps/run-repo-script.ps1 -RepoName $RepoName -ScriptName "setup-environment.ps1" -Options $Options
Write-Output "::endgroup::"

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Output "::group::Build Package Requirements"
./steps/run-repo-script.ps1 -RepoName $Options -ScriptName "build-package-requirements.ps1" -Options $Options
Write-Output "::endgroup::"

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
