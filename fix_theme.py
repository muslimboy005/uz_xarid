import re

path = '/Users/yyy/Downloads/home/uzxarid/lib/features/profile/presentation/pages/my_business_page.dart'
with open(path, 'r') as f:
    text = f.read()

# Add context extensions
vars_str = """    final bodyBg = context.bodyBackground;
    final containerBg = context.surfaceContainer;
    final cardColor = context.cardSurface;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final isDark = context.isDark;"""

text = text.replace("    final bodyBg = context.bodyBackground;\n    final containerBg = context.surfaceContainer;", vars_str)

# Replace scaffold background
text = text.replace("backgroundColor: AppColors.primary,", "backgroundColor: isDark ? AppColors.darkBackground : AppColors.primary,")

# We can replace generic colors first:
text = text.replace("AppColors.black500", "textPrimary")
text = text.replace("AppColors.black300", "textSecondary")
text = text.replace("Colors.grey.shade600", "textSecondary")

text = text.replace("AppColors.black100", "borderColor")
text = text.replace("AppColors.black200", "borderColor")

text = text.replace("AppColors.black50", "containerBg")

# Carefully replace white with cardColor for standard components, but keep specific ones white
text = text.replace("color: AppColors.white,", "color: cardColor,")

# In Dropdown field build method, containerBg, textSecondary and borderColor variables are not defined.
# Need to replace them with context.method or create vars.
dropdown_build = """  @override
  Widget build(BuildContext context) {
    final containerBg = context.surfaceContainer;
    final borderColor = context.borderColor;
    final textSecondary = context.textSecondary;
    return Container("""
text = text.replace("  @override\n  Widget build(BuildContext context) {\n    return Container(", dropdown_build)

text = text.replace("color: AppColors.white", "color: cardColor")
# Now fix "Сохранить" and progress indicator
save_text_find = """AppText(
                                              text: 'Сохранить',
                                              fontSize: 15,
                                              fontWeight: 600,
                                              color: cardColor,
                                            )"""
save_text_replace = """AppText(
                                              text: 'Сохранить',
                                              fontSize: 15,
                                              fontWeight: 600,
                                              color: AppColors.white,
                                            )"""
text = text.replace(save_text_find, save_text_replace)

prog_find = """CircularProgressIndicator(
                                              color: cardColor,
                                            )"""
prog_replace = """CircularProgressIndicator(
                                              color: AppColors.white,
                                            )"""
text = text.replace(prog_find, prog_replace)


with open(path, 'w') as f:
    f.write(text)
