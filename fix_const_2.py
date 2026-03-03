import re

path = 'lib/features/profile/presentation/pages/my_business_page.dart'
with open(path, 'r') as f:
    text = f.read()

text = text.replace("    final textSecondary = context.textSecondary;\n    return Container(", "    return Container(")

with open(path, 'w') as f:
    f.write(text)
