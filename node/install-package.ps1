param (
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [Parameter(Mandatory=$true)]
    [array]$Packages
)

Push-Location $RepoName

# Path to packed packages
$packageFolderPath = "../package";

try {
    # Get all .tgz files in the package folder that match the dependency name
    $tgzFiles = Get-ChildItem -Path $packageFolderPath -Filter "$dependencyFileName-*.tgz"

    if ($tgzFiles.Count -gt 0) {
        # Extract version from the first matching .tgz file
        $tgzFileName = $tgzFiles[0].Name
        $version = [System.IO.Path]::GetFileNameWithoutExtension($tgzFileName) -replace "$dependencyFileName-", ""

        # We are going through all packages to replace their package json
        # We are adding packed package as dependency for it
        foreach ($package in $Packages) {
            $path = Join-Path . $package
            Push-Location $path
            Write-Output "Switching dependencies for $package"

            $filePath = "package.json"

            # Read the content of the package.json file
            $jsonContent = Get-Content $filePath | ConvertFrom-Json

            # Check if the dependency exists in the package.json
            if ($jsonContent.dependencies.$package) {
                # Update the dependency value
                $jsonContent.dependencies.$package = "file:../../package/$package-$version.tgz"
            } else {
                # If the dependency doesn't exist, add it with the new value
                $jsonContent.dependencies.$package = "file:../../package/$package-$version.tgz"
            }

            $jsonContent.dependencies.$dependencyName = $newDependencyValue

            # Convert the updated object back to JSON and write it to the file
            $jsonContent | ConvertTo-Json | Set-Content $filePath

            Write-Host $jsonContent

            # Reinstall packages to be sure that we use our packet packages
            npm install

            Pop-Location
        }
    }
} finally {
    Pop-Location
}

