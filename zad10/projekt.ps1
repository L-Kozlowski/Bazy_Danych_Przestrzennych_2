clear
# CHANGELOG
# DATA UTOWRZENIA/SKOŃCZENIA 14.01.2024r
# OPIS:
# Skrytpt pobiera ze strony agh  plik InternetSales_new.zip
# rozpakowuje go i dokonuje walidacji 
# tworzy nową baze w postgresie z nową tabela i kopiuje dane do nowo powstałej tabeli w postgresie 
# zweryfikowana tabele przenosi do katalogu PROCESSED dodając prefix ${TIMESTAMP}_ 
# aktualizuje kolumne SecretCode w bazie danych losowym stringiem o długości 10
# kopiuje dane z bazy danych do pliku .csv, a następnie go pokuje do pliku .zip
# Po każdym kroku do pliku log w katalogu  PROCESSED jest zapisywana linijka informująca o wykonaniu zadania

# ----------------------- Parametry -----------------------
$Web_url = "http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip"
$password = "bdp2agh"
$Path_directory = "E:/semestr2_mgr/bdp2/zad10/projekt_koniec/"
$sql_username = "postgres"
$sql_hostname = "localhost"
$passBase64 = "THVrYXMyMjAy" 
$indeks_number = "401715"
$table_name = "CUSTOMERS_$indeks_number"

$TIMESTAMP  = Get-Date
$TIMESTAMP = $TIMESTAMP.ToString("MMddyyyy")
$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($Web_url)
$Path_download = $Path_directory + $fileNameWithoutExtension + ".zip"
$Path_unzip = $Path_directory
$Path_errors_file = $Path_directory + $fileNameWithoutExtension + ".bad.txt"
$Path_good_file = $Path_directory + $fileNameWithoutExtension +  ".txt"
$Path_csv_file = $Path_directory + $fileNameWithoutExtension +  ".csv"

$sql_haslo  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($passBase64))
$env:PGPASSWORD="$sql_haslo";

# ----------------------- Plik .log  -----------------------
# Ścieżka do folderu PROCESSED
$processed_path = $Path_directory + "PROCESSED/"
$new_name = $Path_directory + $TIMESTAMP + "_" + $fileNameWithoutExtension +  ".txt"

# Sprawdź istnienie folderu PROCESSED
if (-not (Test-Path -Path $processed_path -PathType Container)) {
    # Jeśli folder nie istnieje, utwórz go
    New-Item -Path $processed_path -ItemType Directory | out-null
}

$script_name = $MyInvocation.MyCommand.Name
$script_name = $script_name.Split(".")
$script_name = $script_name[0]
$log_file = $processed_path +  $script_name + "_" + $TIMESTAMP + ".log"
if (Test-Path $log_file) {
    Remove-Item $log_file -Force
}

function Log ($argument1, $argument2) {
    $czas = Get-Date
    $czasTekstowy = $czas.ToString("HHmmssMMddyy")
    $info = "$czasTekstowy - $argument1 - $argument2"
    Write-Output $info
    $info >> $log_file
}

# -----------------------Pobranie ze strony pliku -----------------------
try {
    Invoke-WebRequest -Uri $Web_url -OutFile $Path_download | out-null
    Log Download Successful

}
catch {
    Log Download Unsuccessful
}

# -----------------------Wypakowanie pliku -----------------------
Function Open-7ZipFile{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination,
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$ExePath7Zip,
        [switch]$Silent
    )
    $Command = "& `"$ExePath7Zip`" e -o`"$Destination`" -y" + $(if($Password.Length -gt 0){" -p`"$Password`""}) + " `"$Source`""
    If($Silent){
        Invoke-Expression $Command | out-null
    }else{
        "$Command"
        Invoke-Expression $Command
    }
}


try {
    Open-7ZipFile -ExePath7Zip "C:\Program Files\7-Zip\7z.exe" -Source $Path_download -Destination $Path_unzip -Password $password | Out-Null

    $Path_file = $Path_unzip + "/InternetSales_new.txt"
    $zawartoscPliku = Get-Content -Path $Path_file
    $arrayList = New-Object System.Collections.ArrayList
    $arrayList.AddRange($zawartoscPliku)
    Log Extract Successful

}
catch {
    Log Extract Unsuccessful
}

# -----------------------Walidacja -----------------------
try {
    if (Test-Path $Path_errors_file) {
        Remove-Item $Path_errors_file -Force
    }
    $txt =  "Length before walidation: " + $arrayList.Count
    Write-Output $txt

    $rows = @{}
    $indeksyPowtarzajacychSieWierszy = @()
    $id_delete = @()
    $why = @()
    $col_names =  $arrayList[0] -split "\|"

    for($i=1; $i -le $arrayList.Count-1; $i++){

        $line = $arrayList[$i]
        $values =  $arrayList[$i] -split "\|"
        $id_column_name = 2
        $seperate_name = $values[$id_column_name] -split ","
        $seperate_name[0] = $seperate_name[0].replace('"','')
        try{
        $seperate_name[1] = $seperate_name[0].replace('"','')
        }catch {}

        # Odrzucenie pustych lini
        if ($line.Length -le 6)
        {
            $id_delete += $i
            $why += "Empty"
        }

        # ilość wiersze, które mają ilość kolumn taką jak nagłówek pliku
        elseif ($values.Count -ne $col_names.Length)
        {
            $id_delete += $i
            $why += "Diff_size"
        }
        # kolumna OrderQuantity może przyjmować maksymalną wartość 100
        elseif ($values[4] -ge 100)
        {
            $id_delete += $i
            $why += "G_100"
        }
        # brak wartości w SecretCode (usuń wszelkie wartości SecretCode przed przeslaniem do pliku .bad),
        elseif ($values[6] -ne "")
        {
            $id_delete += $i
            $why += "Secret_code"
            $values[6] = ""
            #$arrayList[$i] = $values -join "|"

        }
        # Customer_Name powinno być zapisane w formacie "nazwisko,imie",
        elseif ($seperate_name.Count  -ne 2)
        {
            $id_delete += $i
            $why += "Name"
        }

    
        # pozostaw tylko unikalne wiersze
        if ($rows.ContainsKey($line)) {
            $id_delete += $i
            $why += "Not_unique"
        } else {
            $rows[$line] = $i
        }
     
         # dodanie kolumn z osobnym imieniem i nazwiskiem
         $values = $values[0..($id_column_name - 1)] + $seperate_name + $values[($id_column_name + 1)..($values.Count - 1)]
         $arrayList[$i] = $values -join "|"
    }

    # Dodanie nagłówków "FIRST_NAME" and "LAST_NAME"
    $col_names =  $col_names[0..($id_column_name - 1)] + "FIRST_NAME" + "LAST_NAME" + $col_names[($id_column_name + 1)..($col_names.Count - 1)]
    $col_names = $col_names -join "|"
    $arrayList[0] = $col_names

    # Stworzenie słownika z id wierszy do usunięcia oraz przyczyną usunięcia
    $id_delete_unique = $id_delete | Get-Unique
    $d1 = @{}
    for($i=$id_delete.Count-1; $i -ge 0 ; $i--){
        try{
        $d1.Add($id_delete[$i], $why[$i] )
        }catch { }
    }

     # Usunięcie błędnych wierszy i wysłanie do pliku .bad
    for($i=$id_delete_unique.Count-1; $i -ge 0 ; $i--){
        $id = $id_delete_unique[$i]

        $id.ToString() + " - " + $d1[$id] + " - " + $arrayList[$id] >> $Path_errors_file 
        $arrayList.RemoveAt($id)
    }

    $txt =  "Length after walidation: " + $arrayList.Count
    Write-Output $txt 

    # zapisanie do pliku
    $arrayList > $Path_good_file 

    Log Walidation Successful
}
catch {
    Log Walidation Unsuccessful
}

# ----------------------- Tworzenie nowej tabeli i bazy danych -----------------------
 try {
    psql -d postgres -U "$sql_username" --host="$sql_hostname" --port=5432 ` -c "drop database IF EXISTS bdp2" | Out-Null

    psql -d postgres -U "$sql_username" --host="$sql_hostname" --port=5432 `
    --command='CREATE DATABASE bdp2;' `
    --command='\c bdp2' `
    --command="CREATE TABLE IF NOT EXISTS $table_name (
    ProductKey INT, 
    CurrencyAlternateKey VARCHAR(5), 
    FIRST_NAME VARCHAR(100), 
    LAST_NAME VARCHAR(100), 
    OrderDateKey INT, 
    OrderQuantity INT, 
    UnitPrice FLOAT,
    SecretCode VARCHAR(12));" | Out-Null
    
    Log Create_table Successful
}
catch {
    Log Create_table Unsuccessful
}
 
# -----------------------Skopiowanie danych z pliku do bazy -----------------------
 try {
    $file_converted_path = $Path_directory + "file_converted.txt"
    # zamiana w liczbach zmienno przecinkowych "," na ".", takiego zapisu wymaga postgres
    (Get-Content -Path $Path_good_file) -replace ',', '.'  | Out-File -FilePath $file_converted_path -Encoding UTF8 
    psql -d bdp2 -U "$sql_username" --host="$sql_hostname" --port=5432  `
    --command="\COPY $table_name  FROM $file_converted_path ( FORMAT CSV, DELIMITER('|'), HEADER)" | Out-Null

    if (Test-Path $file_converted_path) {
        Remove-Item $file_converted_path -Force
    } else {
        Write-Host "File converted not found"
    }

    Log Load_data Successful
}
catch {
    Log Load_data Unsuccessful
}

# ----------------------- Przeniesienie pliku do podkatalogu -----------------------
 try {
    Rename-Item $Path_good_file $new_name -Force 
    Move-Item -Path $new_name -Destination $processed_path -Force

    Log Move_rename_file Successful
}
catch {
    Log Move_rename_file Unsuccessful
}

# -----------------------Aktualizacja SecretCode -----------------------
 try {
    $command = "CREATE OR REPLACE FUNCTION generate_random_string(length INTEGER)
    RETURNS VARCHAR(10) AS `$`$
    DECLARE
        characters VARCHAR(62) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        random_string VARCHAR(10) := '';
        i INTEGER;
    BEGIN
        FOR i IN 1..length LOOP
            random_string := random_string || substr(characters, floor(random() * length(characters) + 1)::integer, 1);
        END LOOP;

        RETURN random_string;
    END;
    `$`$ LANGUAGE plpgsql;
    " 

    psql -d bdp2 -U "$sql_username" --host="$sql_hostname" --port=5432 `
     --command=$command `
     --command="
    UPDATE $table_name 
    SET SecretCode = generate_random_string(10); 
    "  | Out-Null

    Log Update_SecretCode Successful
}
catch {
    Log Update_SecretCode Unsuccessful
}

# -----------------------Skopiowanie, z bazy, danych do pliku CSV oraz dokonanie kompresji -----------------------
 try {
    psql -d bdp2 -U "$sql_username" --host="$sql_hostname" --port=5432  `
    --command="\COPY (SELECT * FROM $table_name) TO '$Path_csv_file' WITH CSV HEADER;"| Out-Null

    $zip_path = $Path_directory + $fileNameWithoutExtension + "_csv.zip"

    & "C:\Program Files\7-Zip\7z.exe" a -tzip $zip_path $Path_csv_file | Out-Null

    Log Copy_to_CSV Successful
}
catch {
    Log Copy_to_CSV Unsuccessful
}