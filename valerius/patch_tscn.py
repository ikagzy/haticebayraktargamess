import re
import sys

def patch_tscn(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Add resources
        # Find the last ExtResource
        lines = content.split('\n')
        last_ext_idx = -1
        for i, line in enumerate(lines):
            if line.startswith("[ext_resource"):
                last_ext_idx = i

        if last_ext_idx != -1:
            resources_to_add = [
                '[ext_resource type="Script" path="res://parlayan_raf.gd" id="raf_script"]',
                '[ext_resource type="Script" path="res://keypad_sistemi.gd" id="keypad_script"]'
            ]
            lines.insert(last_ext_idx + 1, resources_to_add[1])
            lines.insert(last_ext_idx + 1, resources_to_add[0])

        content = '\n'.join(lines)

        # Shelf D
        content = re.sub(
            r'(\[node name="Shelf D" parent=".".*?\]\ntransform = Transform3D[^\n]*)',
            r'\1\nscript = ExtResource("raf_script")\nparlayan_raf_no = 3',
            content
        )
        
        # Shelf D2
        content = re.sub(
            r'(\[node name="Shelf D2" parent=".".*?\]\ntransform = Transform3D[^\n]*)',
            r'\1\nscript = ExtResource("raf_script")\nparlayan_raf_no = 2',
            content
        )

        # Shelf D3
        content = re.sub(
            r'(\[node name="Shelf D3" parent=".".*?\]\ntransform = Transform3D[^\n]*)',
            r'\1\nscript = ExtResource("raf_script")\nparlayan_raf_no = 1',
            content
        )

        # Shelf D4
        content = re.sub(
            r'(\[node name="Shelf D4" parent=".".*?\]\ntransform = Transform3D[^\n]*)',
            r'\1\nscript = ExtResource("raf_script")\nparlayan_raf_no = 4',
            content
        )

        # SM_Pin_Pad
        content = re.sub(
            r'(\[node name="SM_Pin_Pad" parent=".".*?\]\ntransform = Transform3D[^\n]*)',
            r'\1\nscript = ExtResource("keypad_script")\ndogru_sifre = "3214"\ntv_node_yolu = NodePath("../TV2")',
            content
        )

        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

        print("SUCCESS")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    patch_tscn("kale.tscn")
