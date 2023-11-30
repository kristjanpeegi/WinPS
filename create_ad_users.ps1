#Otsime kasutajate faili koos andmetega
$file = "C:\Users\Administrator\Desktop\WinPS\adkasutajad.csv"
#Impordime faili
$users = Import-Csv $file -Encoding Default -Delimiter ";"
foreach ($user in $users){
    #Kasutajanimi on eesnimi.perekonnanimi
    $username = $user.FirstName + "." + $user.LastName
    $username = $username.ToLower()
    $username = Translit($username)
    $upname = $username + "@sv-kool.local"
    $displayname = $user.FirstName + " " + $user.LastName
    #Kontrollime kas kasutaja on olemas või ei. Kui kasutaja on olemas tuleb viisakas veateade.
    $existingUser = Get-ADUser -Filter {SamAccountName -eq $username}
    if ($existingUser -eq $null) {
        New-ADUser -Name $username -DisplayName $displayname -GivenName $user.FirstName -Surname $user.LastName -Department $user.Department -Title $user.Role -UserPrincipalName $upname -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -force) -Enabled $true
    $LASTEXITCODE = $?
    } else {
        Write-Host "Kasutaja $username on juba olemas!"
        $LASTEXITCODE = 1
    }
}
#Lisame funktsiooni mis muudab UTF-8 sümbolid LATIN charsetile sobivaks
function Translit {
    param(
        [string] $inputString
    )
    #Defineerime sümbolid mis on vaja ära muuta
        $Translit = @{
        [char]"ä" = "a"
        [char]"ü" = "u"
        [char]"õ" = "o"
        [char]"ö" = "o"
        }
    $outputString=""
    foreach ($character in $inputCharacter = $inputString.ToCharArray())
    {
        if ($Translit[$character] -cne $Null ){
        $outputString += $Translit[$character]
    } else {
        $outputString += $character
    }
    }
    Write-Output $outputString
}