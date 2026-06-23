$content = Get-Content -Raw "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\lib\screens\auth\register_screen.dart"

$step2Old = Get-Content -Raw "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\step2_target.txt"
$step3Old = Get-Content -Raw "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\step3_target.txt"

$step2New = Get-Content -Raw "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\step2_new.txt"
$step3New = Get-Content -Raw "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\step3_new.txt"

$content = $content.Replace($step2Old, $step2New)
$content = $content.Replace($step3Old, $step3New)

Set-Content "c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\lib\screens\auth\register_screen.dart" $content -NoNewline
Write-Output "Done."
