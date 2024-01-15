
# ----------------------- Parametry -----------------------
$Web_url = "http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip"
$indeks_number = "401715"
$Path_directory = "E:/semestr2_mgr/bdp2/zad10/PROCESSED/"

$table_name = "CUSTOMERS_$indeks_number"
$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($Web_url)
$TIMESTAMP  = Get-Date
$TIMESTAMP = $TIMESTAMP.ToString("MMddyyyy")
$new_name = $Path_directory + $TIMESTAMP + "_" + $fileNameWithoutExtension +  ".txt"

# ----------------------- Plik pomocniczy z kropkami jako separator dziesiętny -----------------------
$file_converted_path = $Path_directory + "file_converted.txt"
$fmt_path = $Path_directory + "format.fmt"
(Get-Content -Path $new_name) -replace ',', '.'  | Out-File -FilePath $file_converted_path -Encoding UTF8 

# ----------------------- BCP -----------------------
bcp bdp2.dbo.$table_name IN $file_converted_path -S "DESKTOP-OPT4B96\SQL2022" -T -f $fmt_path -F 2

# ----------------------- Usunięcie pliku pomocniczego -----------------------
if (Test-Path $file_converted_path) {
    Remove-Item $file_converted_path -Force
} else {
    Write-Host "File converted not found"
}
