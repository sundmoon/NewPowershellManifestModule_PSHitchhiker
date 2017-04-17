#require Module Plaster

$ignoreplaceholders = @('.\PSHitchhiker\static\locale\en-US\.gitignore'
                        '.\PSHitchhiker\static\template\private\.gitignore'
                        '.\PSHitchhiker\static\template\public\.gitignore')

Remove-Item $ignoreplaceholders -ea SilentlyContinue


$PlasterParams = @{
    TemplatePath = ".\PSHitchhiker"
    Destination = "..\PSHitchhiker_generated"
    ModuleName = 'FooUtil'
    #    ModuleDesc = 'Commands for Foo'
    FullName = 'John Q. Doe'
    Email = 'john.q.doe@example.org'
    GithubUsername = 'sundmoon'
    GithubRepository = 'PSHitchhiker_generated'
    Version = '1.2.0'
    CIURL = "http://levt.theserver.tk:20080/job/PSHitchhiker/"
    #    Options = 'Git', 'PSake', 'Pester'
    Editor = 'VSCode'
    AddCI = 'Yes'
    #    License = 'MIT'
}

Invoke-Plaster @PlasterParams -Force

$ignoreplaceholders  | % {New-item $_; Set-Content -Path $_ -Value 'ignore placeholders for github empty directories'}

