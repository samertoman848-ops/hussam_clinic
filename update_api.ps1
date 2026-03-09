# Save as update_api.ps1 and run from project root (c:\Programming\flutter\hussam)
$files = Get-ChildItem -Path .\lib -Recurse -Filter *.dart
$updated = @()
foreach ($f in $files) {
  $text = Get-Content -Path $f.FullName -Raw
  $orig = $text

  # Fix direct dropdownSearchDecoration -> decoratorProps wrapper
  $text = [regex]::Replace($text, '(?is)dropdownSearchDecoration\s*:\s*InputDecoration\s*\(', 'decoration: InputDecoration(', [Text.RegularExpressions.RegexOptions]::Singleline)

  # Replace dropdownDecoratorProps + nested name -> decoratorProps + decoration (catch cases)
  $text = [regex]::Replace($text, '(?is)dropdownDecoratorProps\s*:\s*DropDownDecoratorProps\s*\(\s*dropdownSearchDecoration\s*:\s*', 'decoratorProps: DropDownDecoratorProps(decoration: ', [Text.RegularExpressions.RegexOptions]::Singleline)

  # Generic replacements for parameter names
  $text = [regex]::Replace($text, '(?i)\bdropdownDecoratorProps\b', 'decoratorProps')
  $text = [regex]::Replace($text, '(?i)\bdropdownSearchDecoration\b', 'decoration')

  # TextTheme deprecated fields -> new names
  $text = $text -replace '\bheadline6\b','titleLarge'
  $text = $text -replace '\bheadline1\b','displayLarge'
  $text = $text -replace '\bheadline5\b','titleMedium'
  $text = $text -replace '\bsubtitle1\b','titleSmall'
  $text = $text -replace '\bbodyText1\b','bodyLarge'
  $text = $text -replace '\bbodyText2\b','bodyMedium'

  # Fix ThemeData(.copyWith -> ThemeData().copyWith or return ThemeData( .copyWith
  $text = [regex]::Replace($text, '(?i)ThemeData\s*\(\s*\.\s*copyWith', 'ThemeData().copyWith')
  $text = [regex]::Replace($text, '(?i)return\s+ThemeData\s*\(\s*\)\s*\.copyWith', 'return ThemeData().copyWith')

  if ($text -ne $orig) {
    Set-Content -Path $f.FullName -Value $text -Encoding UTF8
    $updated += $f.FullName
  }
}

"Updated files: $($updated.Count)"
$updated | ForEach-Object { $_ }