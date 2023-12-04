#Otsime kasutajate faili koos andmetega
$file = "C:\Users\Administrator\Desktop\WinPS\adkasutajad.csv"
$results = @()
#Impordime faili

$users = Import-Csv $file -Encoding Default -Delimiter ";"
foreach ($user in $users){
    #Kasutajanimi on eesnimi.perekonnanimi
    $username = $user.FirstName + "." + $user.LastName
    $username = $username.ToLower()
    $username = Translit($username)
    $upname = $username + "@sv-kool.local"
    $displayname = $user.FirstName + " " + $user.LastName
    $uusParool = GenerateStrongPassword (10)

    #Kontrollime kas kasutaja on olemas või ei. Kui kasutaja on olemas tuleb viisakas veateade.
    $existingUser = Get-ADUser -Filter {SamAccountName -eq $username}
    if ($existingUser -eq $null) {
        New-ADUser -Name $username -DisplayName $displayname -GivenName $user.FirstName -Surname $user.LastName -Department $user.Department -Title $user.Role -UserPrincipalName $upname -AccountPassword (ConvertTo-SecureString $uusParool -AsPlainText -force) -Enabled $true
    $LASTEXITCODE = $?
    $results += [PSCustomObject]@{
        "Username" = $username
        "LoodudParool" = $uusParool
        }
    } else {
        Write-Host "Kasutaja $username on juba olemas!"
        $LASTEXITCODE = 1
    }
}

$results | Export-Csv -Path "C:\Users\Administrator\Desktop\WinPS\kasutajanimi.csv" -NoTypeInformation

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

#Lisame parooligenereerimise funktsiooni
function GenerateStrongPassword ([Parameter(Mandatory=$true)][int]$PasswordLenght)
{
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
        $newPassword=[System.Web.Security.Membership]::GeneratePassword($PasswordLenght,1)
        if ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
        -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
        -and ($newPassword -match "[\d]") `
        -and ($newPassword -match "[^\w]")
        )
        {
            $PassComplexCheck=$True
        }
        } While ($PassComplexCheck -eq $false)
    return $newPassword

}

# Loome varunduskausta
$backupFolder = "C:\Backup"
if (-not (Test-Path -Path $backupFolder)) {
    New-Item -Path $backupFolder -ItemType Directory
}

# Saame kõikide kasutajate loetelu
$allUsers = Get-ADUser -Filter *

foreach ($user in $allUsers){
    $username = $user.SamAccountName

    # Vaatame, kas kasutaja kodukausta eksisteerib
    $userFolder = "C:\Users\$username"
    if (Test-Path -Path $userFolder -PathType Container) {
        $backupFileName = "{0}-{1:dd.MM.yyyy}.zip" -f $username, (Get-Date)
        $backupPath = Join-Path -Path $backupFolder -ChildPath $backupFileName

        # Loome kasutaja kodukausta varunduse
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($userFolder, $backupPath)
        Write-Host "Kasutaja $username kodukausta varundamine on lõpetatud. Varundus asub $backupPath"
    } else {
        Write-Host "Kasutaja $username kodukausta ei leitud."
    }
}