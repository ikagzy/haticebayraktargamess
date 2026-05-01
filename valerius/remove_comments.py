import os
import glob

def remove_comments_from_line(line):
    in_string = False
    string_char = ''
    for i, char in enumerate(line):
        if char in ('"', "'"):
            # Toggle in_string if it's not escaped
            # This is a basic check, might not cover all edge cases like \\"
            if i == 0 or line[i-1] != '\\':
                if not in_string:
                    in_string = True
                    string_char = char
                elif string_char == char:
                    in_string = False
        elif char == '#' and not in_string:
            return line[:i]
    return line

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    modified = False
    for line in lines:
        stripped_line = remove_comments_from_line(line)
        if stripped_line != line:
            modified = True
            # If the line becomes empty or just whitespace after stripping,
            # and it wasn't just whitespace before (meaning the comment was the only thing on the line)
            # we might want to drop it completely.
            if stripped_line.strip() == '' and line.strip().startswith('#'):
                continue # Skip this line
            
            # If it had some code, then a comment, we keep the code part.
            # Rstrip to remove trailing whitespace before the newline, then add newline
            new_lines.append(stripped_line.rstrip() + '\n')
        else:
            new_lines.append(line)
            
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        return True
    return False

if __name__ == "__main__":
    count = 0
    # Process all .gd files recursively
    for root, _, files in os.walk('.'):
        for file in files:
            if file.endswith('.gd'):
                filepath = os.path.join(root, file)
                if process_file(filepath):
                    count += 1
    
    print(f"Total files modified: {count}")
