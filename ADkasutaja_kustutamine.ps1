# Funktsioon sümbolite asendamiseks
function Translit {
    param(
        [string] $inputString
    )
    
    $Translit = @{
        [char]"ä" = "a"
        [char]"ü" = "u"
        [char]"õ" = "o"
        [char]"ö" = "o"
    }

    $outputString=""
    foreach ($character in $inputString.ToCharArray())
    {
        if ($Translit[$character] -cne $null) {
            $outputString += $Translit[$character]
        } else {
            $outputString += $character
        }
    }
    return $outputString
}

# Küsi kasutajalt ees- ja perenimi
$firstName = Read-Host -Prompt "Sisesta kasutaja eesnimi"
$lastName = Read-Host -Prompt "Sisesta kasutaja perekonnanimi"

# Loome kasutajanime ja teostame sümbolite asenduse
$username = $firstName + "." + $lastName
$username = $username.ToLower()
$username = Translit -inputString $username

# Kustutame kasutaja Active Directory-st
try {
    Remove-ADUser -Identity $username -Confirm:$false -ErrorAction Stop
    Write-Host "Kasutaja $username on edukalt kustutatud Active Directory-st."
} catch {
    Write-Host "Viga: Kasutajat $username ei leitud või kustutamine ebaõnnestus."
}