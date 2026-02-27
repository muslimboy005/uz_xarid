import sys
import re

def remove_breadcrumb(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove import
    content = re.sub(r"import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';\n", "", content)
    
    # Simple nested parenthesis matcher
    def find_breadcrumb(text):
        start_idx = text.find('ProfileBreadcrumb(')
        if start_idx == -1: return -1, -1
        
        paren_count = 0
        in_string = False
        string_char = ''
        
        # Start searching from the '('
        paren_start = start_idx + len('ProfileBreadcrumb')
        for i in range(paren_start, len(text)):
            c = text[i]
            if in_string:
                if c == string_char and text[i-1] != '\\':
                    in_string = False
            else:
                if c in ("'", '"'):
                    in_string = True
                    string_char = c
                elif c == '(':
                    paren_count += 1
                elif c == ')':
                    paren_count -= 1
                    if paren_count == 0:
                        return start_idx, i + 1
        return -1, -1

    modified = False
    while True:
        start, end = find_breadcrumb(content)
        if start != -1:
            modified = True
            
            # Remove trailing commas and whitespace
            remove_end = end
            while remove_end < len(content) and content[remove_end] in (' ', '\n', '\t', ','):
                remove_end += 1
            
            # Preserve spacing if we removed too much indentation
            content = content[:start] + content[remove_end:]
        else:
            break
            
    if modified:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

if __name__ == '__main__':
    for arg in sys.argv[1:]:
        remove_breadcrumb(arg)
