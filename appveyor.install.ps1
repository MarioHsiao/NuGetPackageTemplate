# Regular expression for matching semantic versioning (http://semver.org/)
$regex = "^v(?<version>(?<major>\d+)\.(?<minor>\d+)\.(?<revision>\d+))(?<prerelease>(?:\-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?)(?<metadata>(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?)$"

If (!$env:APPVEYOR_PULL_REQUEST_NUMBER -and ($env:APPVEYOR_REPO_BRANCH -eq "master") -and ($env:APPVEYOR_REPO_COMMIT_MESSAGE -match $regex))
{
  # Commit message consists of a 'v' followed by a valid semantic version string (e.g. "v1.23.4-beta+exp.sha.5114f85")

  # Treat this as a versioned deploy (possibly a prerelease version)
  $env:RELEASE = $true
  Write-Host "Preparing to release..."

  # Only update assembly version on breaking changes (major version increments)
  $env:ASSEMBLY_VERSION = $matches['major'] + ".0.0"
  # File version includes NuGet release number plus build number
  $env:ASSEMBLY_FILE_VERSION = $matches['version'] + "." + $env:APPVEYOR_BUILD_NUMBER
  # NuGet doesn't allow any build metadata (+) or dots in prerelease tags (-)
  $env:ASSEMBLY_INFORMATIONAL_VERSION = $matches['version'] + ($matches['prerelease'] -replace "\.", "")

  # Set pre-release to true if the prerelease section of the version string exists
  $env:PRERELEASE = !!($matches['prerelease']) -or ($matches['major'] -eq '0')
  $env:RELEASE_TAG = $env:APPVEYOR_REPO_COMMIT_MESSAGE
  $env:RELEASE_TITLE = "Version " + ($env:APPVEYOR_REPO_COMMIT_MESSAGE).substring(1)
}
Else
{
  # Do not assign a release number or deploy to NuGet
  $env:DEPLOY_NUGET = $false

  $env:ASSEMBLY_VERSION = "0.0.0"
  $env:ASSEMBLY_FILE_VERSION = "0.0.0." + $env:APPVEYOR_BUILD_NUMBER
  $env:ASSEMBLY_INFORMATIONAL_VERSION = "0.0.0-" + ($env:APPVEYOR_REPO_BRANCH -replace "[^0-9A-Za-z]", "") + "-" + $env:APPVEYOR_BUILD_NUMBER
}

Write-Host "Assembly version" $env:ASSEMBLY_VERSION
Write-Host "Assembly file version" $env:ASSEMBLY_FILE_VERSION
Write-Host "Assembly informational version" $env:ASSEMBLY_INFORMATIONAL_VERSION

# Set release notes for NuGet package
$env:releaseNotes = $env:APPVEYOR_REPO_COMMIT_MESSAGE
