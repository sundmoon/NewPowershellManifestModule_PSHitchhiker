#Requires -Modules InvokeBuild,Plaster
#by Roman Kuzmin @nightroman

$Destination = 'C:\PSHitchhiker'
$PlasterTemplates = 'C:\Users\Operator\.vscode\extensions\ms-vscode.powershell-0.12.2\modules\Plaster\Templates'
$PSHitchhikerTemplate = "$PlasterTemplates\NewPowershellManifestModule_PSHitchhiker"

Task . Build

Task Build Clean, Plaster, InstallTemplate

Task Clean {
    Remove-Item $Destination -Recurse -ea SilentlyContinue
    Remove-Item $PSHitchhikerTemplate -Recurse -ErrorAction SilentlyContinue
}

Task Plaster Clean, {
    Invoke-Plaster .\PSHitchhiker -DestinationPath $Destination -NoLogo
}

Task InstallTemplate Plaster, {
    Copy-Item .\PSHitchhiker -Destination $PSHitchhikerTemplate -Recurse
}




