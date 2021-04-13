. .\src\Objects.ps1
. .\src\Handlers.ps1

$Host.UI.RawUI.BackgroundColor = "black"
$farm = New-FarmBuilder

do {
    Clear-Host
    Write-Host "Which breed do you want to know about?`n" -ForegroundColor Green
    Write-Breeds -Farm $farm
    Write-Host ""

    Write-Host " [+]: to Add to collection (ex: +2)"
    Write-Host " [-]: to Remove from collection (ex: -10)"
    Write-Host " [R]: to Reset collection"
    Write-Host " [Q]: to Quit`n"

    $selection = Read-Host
    switch ($selection) {
        { $_ -gt 0 -and $_ -le $farm.Chickens.Length } {
            $selection = $selection - 1
            Get-Mating -Breed $farm.Chickens[$selection].Breed -Farm $farm
            Get-Matings -Breed $farm.Chickens[$selection].Breed -Farm $farm
        }
        { $_.StartsWith("+") } {
            $target = $selection.Replace("+", "")
            if ((Confirm-IfInteger -ValueToTest $target) -and ([int]$target -gt 0) -and ([int]$target -le $farm.Chickens.Count)) {
                Add-ToCollection -NewBreed $farm.Chickens[$target - 1].Breed
            } else {Write-Host "Problem with the input given." -ForegroundColor Red}
        }
        { $_.StartsWith("-") } {
            $target = $selection.Replace("-", "")
            if ((Confirm-IfInteger -ValueToTest $target) -and ([int]$target -gt 0) -and ([int]$target -le $farm.Chickens.Count)) {
                Remove-FromCollection -RemoveBreed $farm.Chickens[$target - 1].Breed
            } else {Write-Host "Problem with the input given." -ForegroundColor Red}
        }
        "R" { Clear-Collection }
        "Q" { Write-Host "Thanks for stopping by!" -ForegroundColor Cyan }
        Default {
            Write-Host "Not sure what that is.. Please try again or Q to quit." -ForegroundColor Red
        }
    }
    Write-Host ""
    Pause
}while ($selection -ne 'Q')
