$content = Get-Content -Path "kale.tscn" -Raw -Encoding UTF8

$resources = @"
[ext_resource type="Script" path="res://parlayan_raf.gd" id="raf_script"]
[ext_resource type="Script" path="res://keypad_sistemi.gd" id="keypad_script"]
"@

$content = $content -replace '(?m)^(\[ext_resource type="PackedScene" uid=".*?" path="res://models/Low Poly Furniture/Chairs/TV.glb" id="50_a883v"\])$', "`$1`n$resources"

$content = $content -replace '(?m)^(\[node name="Shelf D" parent="\." unique_id=1756138477 .*?\r?\ntransform = Transform3D[^\n]*)', "`$1`nscript = ExtResource(`"raf_script`")`nparlayan_raf_no = 3"
$content = $content -replace '(?m)^(\[node name="Shelf D2" parent="\." unique_id=97944613 .*?\r?\ntransform = Transform3D[^\n]*)', "`$1`nscript = ExtResource(`"raf_script`")`nparlayan_raf_no = 2"
$content = $content -replace '(?m)^(\[node name="Shelf D3" parent="\." unique_id=1522295142 .*?\r?\ntransform = Transform3D[^\n]*)', "`$1`nscript = ExtResource(`"raf_script`")`nparlayan_raf_no = 1"
$content = $content -replace '(?m)^(\[node name="Shelf D4" parent="\." unique_id=349937086 .*?\r?\ntransform = Transform3D[^\n]*)', "`$1`nscript = ExtResource(`"raf_script`")`nparlayan_raf_no = 4"

$content = $content -replace '(?m)^(\[node name="SM_Pin_Pad" parent="\." unique_id=449540473 .*?\r?\ntransform = Transform3D[^\n]*)', "`$1`nscript = ExtResource(`"keypad_script`")`ndogru_sifre = `"3214`"`ntv_node_yolu = NodePath(`"../TV2`")"

Set-Content -Path "kale.tscn" -Value $content -Encoding UTF8
Write-Output "SUCCESS"
