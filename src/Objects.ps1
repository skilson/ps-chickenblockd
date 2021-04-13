class Chicken {
    [string] $Breed
    [string[]] $Parents
    [string] $SpecialDetails

    Chicken([string]$Breed, [string[]]$Parents, [string]$SpecialDetails) {
        $this.Breed = $Breed
        $this.Parents = $Parents
        $this.SpecialDetails = $SpecialDetails
    }

    [PSCustomObject] ConvertToPSCustomObject() {
        return [PSCustomObject]@{
            Breed = $this.Breed
            Parents = $this.Parents
            SpecialDetails = $this.SpecialDetails
        }
    }
}

class Farm {
    [Chicken[]] $Chickens

    [void] AddChicken([Chicken]$chicken) {
        $this.Chickens = $this.Chickens + $chicken
    }

    [Chicken[]] ShowFarm() {
        return $this.Chickens | Sort-Object -Property Breed
    }

    [string[]] ListAllBreeds() {
        return $this.Chickens.Breed | Sort-Object
    }

    [Chicken] GetMating([string] $Breed) {
        return $this.Chickens | Where-Object { $_.Breed -eq $Breed }
    }

    [Chicken[]] GetMatings([string] $Breed) {
        return $this.Chickens | Sort-Object -Property Breed | Where-Object { $_.Parents -contains $Breed }
    }
}
