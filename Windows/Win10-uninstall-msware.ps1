Write-Output "Removing Xbox related packages..."
Get-AppxPackage -AllUsers "Microsoft.Xbox*" | Remove-AppxPackage

Write-Output "Removing Zune Video & Music..."
Get-AppxPackage -AllUsers "Microsoft.Zune*" | Remove-AppxPackage

Write-Output "Removing other MS crap..."
Get-AppxPackage -AllUsers "Microsoft.3DBuilder" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Appconnector" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Bing*" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.CommsPhone" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Getstarted" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Office.OneNote" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.People" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.SkypeApp" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.WindowsPhone" | Remove-AppxPackage
