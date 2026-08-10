import os
import re

main_path = "lib/main.dart"
screens_dir = "lib/screens"

os.makedirs(screens_dir, exist_ok=True)

with open(main_path, "r") as f:
    content = f.read()

classes_to_extract = {
    "OnboardingScreen": "onboarding_screen.dart",
    "HomeScreen": "home_screen.dart",
    "GuideScreen": "guide_screen.dart",
    "LegalScreen": "guide_screen.dart",
    "TimelineScreen": "timeline_screen.dart",
    "PaywallScreen": "paywall_screen.dart",
    "ExportScreen": "export_screen.dart",
}

class_indices = []
for cls in classes_to_extract.keys():
    match = re.search(r'^class ' + cls + r' (extends|implements).*?\{', content, re.MULTILINE)
    if match:
        class_indices.append((match.start(), cls))

class_indices.sort()
class_indices.append((len(content), "END"))

files_content = {v: "import 'package:flutter/material.dart';\n" for v in classes_to_extract.values()}
files_content["home_screen.dart"] += "import 'guide_screen.dart';\nimport 'timeline_screen.dart';\nimport 'paywall_screen.dart';\nimport 'export_screen.dart';\n"
files_content["timeline_screen.dart"] += "import 'guide_screen.dart';\nimport 'export_screen.dart';\n"
files_content["paywall_screen.dart"] += "import 'guide_screen.dart';\n"
files_content["export_screen.dart"] += "import 'guide_screen.dart';\n"
files_content["onboarding_screen.dart"] += "import 'home_screen.dart';\n"

main_content = content[:class_indices[0][0]]
main_imports = "import 'screens/onboarding_screen.dart';\n"
main_content = main_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + main_imports)

for i in range(len(class_indices) - 1):
    start = class_indices[i][0]
    end = class_indices[i+1][0]
    cls = class_indices[i][1]
    
    class_code = content[start:end]
    filename = classes_to_extract[cls]
    files_content[filename] += "\n" + class_code

for filename, code in files_content.items():
    with open(os.path.join(screens_dir, filename), "w") as f:
        f.write(code)

with open(main_path, "w") as f:
    f.write(main_content)

print("Refactoring complete.")
