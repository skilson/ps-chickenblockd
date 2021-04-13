. .\src\Objects.ps1

Function Write-Breeds([Farm]$Farm) {
    $breeds = $Farm.ListAllBreeds()
    $pad = ($breeds | Measure-Object -Maximum -Property Length).Maximum + 10
    $collection = $(Get-Collection).BreedsCollected
    $index = 0
    while ($index -lt $breeds.Count) {
        $breeds[$index] = "[$($index+1)]: $($breeds[$index])"
        $index++
    }
    $breedColumns = Get-BreedColumns -Breeds $breeds

    $index = 0
    while ($index -lt $breedColumns[0].Count) {
        for ($column = 0; $column -lt $breedColumns.Count; $column++) {
            if ($index -lt $breedColumns[$column].Count) {
                Write-ComparedToCollection -Value $breedColumns[$column][$index] -Collection $collection -Pad $pad
            }
        }
        Write-Host ""
        $index++
    }
}

Function Write-ComparedToCollection([string]$Value, [string[]]$Collection, [int]$Pad) {
    $prefix = $Value.Substring(0, $Value.IndexOf(" ") + 1)
    $strippedValue = $Value.Replace($prefix, "")
    if ($Collection -contains $strippedValue) {
        Write-Host " $($prefix)" -ForegroundColor Green -NoNewline
        Write-Host $strippedValue.PadRight($Pad - $prefix.Length) -NoNewline
    }
    else {
        Write-Host " $($Value.PadRight($Pad))" -NoNewline
    }
}

Function Get-BreedColumns([string[]]$Breeds) {
    $countInColumns = [math]::Floor($breeds.count / 4)
    $remainder = $breeds.count % 4

    $firstExtra = if ($remainder -gt 0) { 1 }else { 0 }
    $firstOffset = ($countInColumns + $firstExtra)
    [string[]]$firstColumn = $breeds[0..($firstOffset - 1)]

    $secondExtra = if ($remainder -gt 1) { 1 }else { 0 }
    $secondOffset = ($countInColumns + $secondExtra + $firstOffset)
    [string[]]$secondColumn = $breeds[($firstOffset)..($secondOffset - 1)]

    $thirdExtra = if ($remainder -gt 2) { 1 }else { 0 }
    $thirdOffset = ($countInColumns + $thirdExtra + $secondOffset)
    [string[]]$thirdColumn = $breeds[($secondOffset)..($thirdOffset - 1)]

    [string[]]$fourthColumn = $breeds[($thirdOffset)..($breeds.Count - 1)]

    return @($firstColumn, $secondColumn, $thirdColumn, $fourthColumn)
}

Function Get-Mating([string]$Breed, [Farm] $Farm) {
    $mating = $Farm.GetMating($Breed)
    if ($mating.Parents[0] -eq '-') {
        Write-Host "`n$($Breed) $($mating.SpecialDetails)" -ForegroundColor Green
        return
    }
    Write-Host "`n$($Breed) " -ForegroundColor Green -NoNewline
    Write-Host "is produced by breeding " -NoNewline
    Write-Host $mating.Parents[0] -ForegroundColor Cyan -NoNewline
    Write-Host " with " -NoNewline
    Write-Host $mating.Parents[1] -ForegroundColor Cyan
}

Function Get-Matings([string]$Breed, [Farm] $Farm) {
    $matings = $Farm.GetMatings($Breed)
    if (!$matings.Count -gt 0) {
        Write-Host "`n$Breed currently has no known matings." -ForegroundColor Green
        return
    }
    Write-Host "`n$Breed Produces:" -ForegroundColor Green
    $matings | Foreach-Object {
        Write-Host "    " -NoNewline
        Write-Host $_.Breed -ForegroundColor Cyan -NoNewline
        Write-Host " when bred with " -NoNewline
        $_.Parents | ForEach-Object {
            if ($_ -ne $Breed) {
                Write-Host $_ -ForegroundColor Cyan
            }
        }
    }
}

Function New-FarmBuilder {
    $list = Get-Content .\data\chickenData.csv | ConvertFrom-Csv  -Delimiter "," | Sort-Object -Property Breed

    [Farm] $farm = [Farm]::new()

    foreach ($line in $list) {
        [Chicken]$chickenIterator = [Chicken]::new($line.Breed, @($line.Parent_1, $line.Parent_2), $line.Special_Care)
        $farm.AddChicken($chickenIterator)
    }

    return $farm
}

Function Get-Collection {
    $collection = @()
    $collection += Import-CSV .\data\collectionData.csv

    return [Object[]]$collection
}

Function Add-ToCollection([string]$NewBreed) {
    [Object[]]$collection = Get-Collection
    $newToCollection = New-Object PsObject -Property @{ BreedsCollected = $NewBreed }
    if ($collection.BreedsCollected -contains $newToCollection.BreedsCollected) {
        Write-Host "Already Collected $NewBreed" -ForegroundColor Red
    }
    else {
        ($collection += $newToCollection) | Export-Csv -Path .\data\collectionData.csv
        Write-Host "Added $NewBreed to Collection" -ForegroundColor Green
    }
}

Function Remove-FromCollection([string]$RemoveBreed) {
    [Object[]]$collection = Get-Collection
    $breedToRemove = New-Object PsObject -Property @{ BreedsCollected = $RemoveBreed }
    if ($collection.BreedsCollected -contains $breedToRemove.BreedsCollected) {
        ($collection | Where-object{$_ -notmatch $breedToRemove}) | Export-Csv -Path .\data\collectionData.csv
        Write-Host "Removed $RemoveBreed from Collection" -ForegroundColor Green
    }
    else {
        Write-Host "Collection does not contain $RemoveBreed" -ForegroundColor Red
    }
}

Function Clear-Collection{
    Clear-Content .\data\collectionData.csv
}

Function Confirm-IfInteger($ValueToTest){
    $control = 0
    $isNum = [System.Int32]::TryParse($ValueToTest, [ref]$control)

    return $isNum
}