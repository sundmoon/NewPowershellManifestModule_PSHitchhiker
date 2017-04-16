# Include: Settings
. './<%=$PLASTER_PARAM_ModuleName%>.settings.ps1'

# Include: build_utils
. './build_utils.ps1'

# Synopsis: Run/Publish Tests and Fail Build on Error
task Test RunTests, ConfirmTestsPassed

# Synopsis: Executes before the Test Task.
# task BeforeTest {} -Before Test {}

# Synopsis: Executes after the Test Task.
# task AfterTest {} -After Test {}


# Synopsis: Run full Pipleline.
task . Clean, Analyze, Analyze, Test, Archive, Publish

# Synopsis: Install Build Dependencies
task InstallDependencies {
    # Cant run an Invoke-Build Task without Invoke-Build.
    Install-Module -Name InvokeBuild

    Install-Module -Name DscResourceTestHelper
    Install-Module -Name Pester -Force -SkipPublisherCheck
    Install-Module -Name PSScriptAnalyzer
}

# Synopsis: Clean Artifacts Directory

task Clean {
    if(Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force

    # Temp
    & git clone https://github.com/Xainey/PSTestReport.git
}


# Synopsis: Analyze Artifacts Directory
task Analyze {
    if(Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force

    # Temp
    & git clone https://github.com/Xainey/PSTestReport.git
}


# Synopsis: Executes before the Analyze task.
# task BeforeAnalyze -Before Analyze {}

# Synopsis: Executes after the Analyze task.
# task AfterAnalyze -After Analyze {}


# Synopsis: Lint Code with PSScriptAnalyzer
task Analyze {
    $scriptAnalyzerParams = @{
        Path = $ModulePath
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}


# Synopsis: Executes before the Analyze task.
# task BeforeAnalyze -Before Analyze {}

# Synopsis: Executes after the Analyze task.
# task AfterAnalyze -After Analyze {}


# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
task RunTests {
    $invokePesterParams = @{
        OutputFile =  (Join-Path $Artifacts "TestResults.xml")
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    # Save Test Results as JSON
    $testresults | ConvertTo-Json -Depth 5 | Set-Content  (Join-Path $Artifacts "PesterResults.json")

    # Old: Publish Code Coverage as HTML
    # $moduleInfo = @{
    #     TestResults = $testResults
    #     BuildNumber = $BuildNumber
    #     Repository = $Settings.Repository
    #     PercentCompliance  = $PercentCompliance
    #     OutputFile =  (Join-Path $Artifacts "Coverage.htm")
    # }
    #
    # Publish-CoverageHTML @moduleInfo

    # Temp: Publish Test Report
    $options = @{
        BuildNumber = $BuildNumber
        GitRepo = $Settings.GitRepo
        GitRepoURL = $Settings.ProjectUrl
        CiURL = $Settings.CiURL
        ShowHitCommands = $true
        Compliance = ($PercentCompliance / 100)
        ScriptAnalyzerFile = (Join-Path $Artifacts "ScriptAnalyzerResults.json")
        PesterFile =  (Join-Path $Artifacts "PesterResults.json")
        OutputDir = "$Artifacts"
    }

    . ".\PSTestReport\Invoke-PSTestReport.ps1" @options
}

# Synopsis: Throws and error if any tests do not pass for CI usage
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path $Artifacts "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path $Artifacts "PesterResults.json") | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

# Synopsis: Creates Archived Zip and Nuget Artifacts
task Archive {
    $moduleInfo = @{
        ModuleName = $ModuleName
        BuildNumber = $BuildNumber
    }

    Publish-ArtifactZip @moduleInfo

    $nuspecInfo = @{
        packageName = $ModuleName
        author =  $Settings.Author
        owners = $Settings.Owners
        licenseUrl = $Settings.LicenseUrl
        projectUrl = $Settings.ProjectUrl
        packageDescription = $Settings.PackageDescription
        tags = $Settings.Tags
        destinationPath = $Artifacts
        BuildNumber = $BuildNumber
    }

    Publish-NugetPackage @nuspecInfo
}


# Synopsis: Executes before the Archive task.
# task BeforeArchive -Before Archive {}

# Synopsis: Executes after the Archive task.
# task AfterArchive -After Archive {}


# Synopsis: Publish to SMB File Share
task Publish {
    $moduleInfo = @{
        RepoName = $Settings.SMBRepoName
        RepoPath = $Settings.SMBRepoPath
        ModuleName = $ModuleName
        ModulePath = "$ModulePath\$ModuleName.psd1"
        BuildNumber = $BuildNumber
    }

    Publish-SMBModule @moduleInfo -Verbose
}


# Synopsis: Executes before the Publish task.
# task BeforePublish -Before Publish {}

# Synopsis: Executes after the Publish task.
# task AfterPublish -After Publish {}