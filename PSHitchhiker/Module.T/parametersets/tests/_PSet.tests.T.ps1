$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

# Since we match the srs/tests organization this works
$here = $here -replace 'tests', '<%=$PLASTER_PARAM_ModuleName%>'

. "$here\$sut"

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\<%=$PLASTER_PARAM_ModuleName%>\<%=$PLASTER_PARAM_ModuleName%>.psm1") -Force

InModuleScope "<%=$PLASTER_PARAM_ModuleName%>" {
    Describe "Public/<%=$PLASTER_PARAM_PSET1%>" {
        Context "<%=$PLASTER_PARAM_PSET1_CONTEXT1%>" {
            It "<%=$PLASTER_PARAM_PSET1_CONTEXT1_IT1%>" {

            }
            It "<%=$PLASTER_PARAM_PSET1_CONTEXT1_IT2%>" {

            }
        }
        Context "<%=$PLASTER_PARAM_PSET1_CONTEXT2%>" {

            It "<%=$PLASTER_PARAM_PSET1_CONTEXT2_IT1%>" {

            }
        }
    }
}