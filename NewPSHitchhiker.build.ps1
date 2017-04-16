Task . Build

Task Build Reinstall

Task Plaster {
    $Destination = 'PSHitchhiker'
    Remove-Item "C:\$Destination" -Recurse -ea SilentlyContinue
    Invoke-Plaster .\PSHitchhiker -DestinationPath "C:\$Destination" -NoLogo
}


Task Reinstall {
    $PlasterTemplates = 'C:\Users\Operator\.vscode\extensions\ms-vscode.powershell-0.12.2\modules\Plaster\Templates'
    Remove-Item "$PlasterTemplates\PSHitchhiker" -Recurse -ErrorAction SilentlyContinue
    Copy-Item .\PSHitchhiker -Destination $PlasterTemplates -Recurse
}
