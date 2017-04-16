$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', '<%=$PLASTER_PARAM_ModuleName%>'

. "$here\$sut"

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\<%=$PLASTER_PARAM_ModuleName%>\<%=$PLASTER_PARAM_ModuleName%>.psm1") -Force

InModuleScope "<%=$PLASTER_PARAM_ModuleName%>" {
    Describe "Public/Invoke-<%=$PLASTER_PARAM_ModuleName%>" {
        Context "Ask" {
            It "Asks a question" {
                {Invoke-<%=$PLASTER_PARAM_ModuleName%> -Ask "Is the cake a lie?" } | Should Not Throw
            }
            It "specifies a format" {
                {Invoke-<%=$PLASTER_PARAM_ModuleName%> -Ask "Is the cake a lie?" -Format integer } | Should Not Throw
            }
        }
        Context "Help" {
            It "gets the docs" {
                {Invoke-<%=$PLASTER_PARAM_ModuleName%> -Help } | Should Not Throw
            }
        }
    }
}