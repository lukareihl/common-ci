param (
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [Parameter(Mandatory=$true)]
    [array]$Packages
)

Push-Location $RepoName

# Path to packed packages
$packageFolderPath = "../../package";

try {
    foreach ($package in $Packages) {
        $path = Join-Path . $package
        Push-Location $path
        Write-Output "Switching dependencies for $package"

        $filePath = "package.json"

        # Read the content of the package.json file
        $jsonContent = Get-Content $filePath | ConvertFrom-Json

        # Loop through dependencies and check if they start with "file:../"
        foreach ($dependency in $jsonContent.dependencies.PSObject.Properties) {
            $dependencyName = $dependency.Name
            $dependencyValue = $dependency.Value

            if ($dependencyValue -match "^file:\.\./(.+)") {
                $dependencyFileName = $Matches[1]

                # Get all .tgz files in the package folder that match the dependency name
                $tgzFiles = Get-ChildItem -Path $packageFolderPath -Filter "$dependencyFileName-*.tgz"

                if ($tgzFiles.Count -gt 0) {
                    # Extract version from the first matching .tgz file
                    $tgzFileName = $tgzFiles[0].Name
                    $version = [System.IO.Path]::GetFileNameWithoutExtension($tgzFileName) -replace "$dependencyFileName-", ""
                    $newDependencyValue = "file:../../package/$dependencyFileName-$version.tgz"
                    $jsonContent.dependencies.$dependencyName = $newDependencyValue
                }
            }
        }

        # Convert the updated object back to JSON and write it to the file
        $jsonContent | ConvertTo-Json | Set-Content $filePath

        # Reinstall packages to be sure that we use our packet packages
        npm install

        Pop-Location
    }
} finally {
    Pop-Location
}

