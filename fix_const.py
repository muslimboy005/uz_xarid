import re

path = 'lib/features/profile/presentation/pages/my_business_page.dart'
with open(path, 'r') as f:
    text = f.read()

text = text.replace("    return Container(", "    final textSecondary = context.textSecondary;\n    return Container(")

# 1. withOpacity -> withValues(alpha: ...)
text = re.sub(r'\.withOpacity\(\s*([\d\.]+),\s*\)', r'.withValues(alpha: \1)', text)
text = text.replace(".withOpacity(0.1)", ".withValues(alpha: 0.1)")

# 2. prefixIcon: const Icon( -> prefixIcon: Icon(
text = text.replace("prefixIcon: const Icon(\n", "prefixIcon: Icon(\n")

# 3. TextStyle (hint)
text = text.replace("const TextStyle(fontSize: 14, color: textSecondary)", "TextStyle(fontSize: 14, color: textSecondary)")

# 4. Keyboard arrow icon
text = text.replace("icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary)", "icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary)")

with open(path, 'w') as f:
    f.write(text)
