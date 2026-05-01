import os
import re

bad_words = [
    'zenci', 'sikis', 'sikiş', 'porno', 'sex', 'seks', 'amcik', 'amcık',
    'yarak', 'yarrak', 'oc', 'oç', 'orospu', 'pic', 'piç', 'gavat', 'kahpe',
    'virus', 'trojan', 'malware', 'hack', 'suç', 'suc'
]

def scan_project():
    suspicious_files = []
    suspicious_contents = []

    for root, dirs, files in os.walk('.'):
        # Skip hidden directories like .git
        if '.git' in root or '.godot' in root:
            continue
            
        for file in files:
            file_lower = file.lower()
            filepath = os.path.join(root, file)
            
            # Check filename
            for word in bad_words:
                if word in file_lower:
                    suspicious_files.append(filepath)
                    break
            
            # Check content for text files
            if file.endswith(('.gd', '.tscn', '.tres', '.txt', '.md', '.json', '.cfg')):
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                        lines = f.readlines()
                        for i, line in enumerate(lines):
                            line_lower = line.lower()
                            for word in bad_words:
                                # basic word boundary check to avoid false positives on 'suc' like 'success'
                                if re.search(r'\b' + re.escape(word) + r'\b', line_lower):
                                    suspicious_contents.append((filepath, i + 1, word))
                                    break
                except Exception as e:
                    pass

    print("=== SUSPICIOUS FILE NAMES ===")
    if not suspicious_files:
        print("None found.")
    else:
        for f in suspicious_files:
            print(f)
            
    print("\n=== SUSPICIOUS FILE CONTENTS ===")
    if not suspicious_contents:
        print("None found.")
    else:
        # Limit the output to avoid huge text
        for f, line, word in suspicious_contents[:50]:
            print(f"File: {f} | Line: {line} | Word: {word}")
        if len(suspicious_contents) > 50:
            print(f"... and {len(suspicious_contents) - 50} more instances.")

if __name__ == '__main__':
    scan_project()
