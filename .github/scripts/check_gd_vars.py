import os
import re

def check_gd_file(filepath):
    issues = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for lineno, line in enumerate(f, 1):
            # Check var declarations
            if var_match := re.match(r'\s*var\s+(\w+)', line):
                var_name = var_match.group(1)
                if not var_name.islower():
                    issues.append(f"{filepath}:{lineno} - 'var {var_name}' must be snake_case.")

            # Check func declarations
            if func_match := re.match(r'\s*func\s+(\w+)', line):
                func_name = func_match.group(1)
                if not func_name.islower():
                    issues.append(f"{filepath}:{lineno} - 'func {func_name}' must be snake_case.")

            # Check const declarations
            if const_match := re.match(r'\s*const\s+(\w+)', line):
                const_name = const_match.group(1)
                if not const_name.isupper():
                    issues.append(f"{filepath}:{lineno} - 'const {const_name}' must be CONSTANT_CASE.")
			
			# Check class_name (must be PascalCase)
            if class_match := re.match(r'\s*class_name\s+(\w+)', line):
                class_name = class_match.group(1)
                if not re.fullmatch(r'[A-Z][a-zA-Z0-9]*', class_name):
                    issues.append(f"{filepath}:{lineno} - 'class_name {class_name}' must be PascalCase.")

    return issues

def check_filename(filepath):
	issues = []
	filename = os.path.basename(filepath)
	name, ext = os.path.splitext(filename)
	# Must be snake_case
	if not re.fullmatch(r'[a-z0-9_]+', name):
		issues.append(f"{filepath} - filename '{filename}' must be snake_case.")
	return issues


def main():
	failed = False
	for root, _, files in os.walk('.'):
		for file in files:
			issues = []
			path = os.path.join(root, file)
			if file.endswith('.gd'):
				if "addons" in path.replace("\\", "/").split("/"):
					continue
				
				issues.extend(check_gd_file(path))
				issues.extend(check_filename(path))
                
			if file.endswith('.png') or file.endswith('.mp3') or file.endswith('.tscn') or file.endswith('.ogg'):
				if "addons" in path.replace("\\", "/").split("/"):
					continue
				issues.extend(check_filename(path))
			if len(issues) > 0:
				for issue in issues:
					print(issue)
					failed = True
	if failed:
		exit(1)

if __name__ == "__main__":
    main()
