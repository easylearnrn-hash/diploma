import re

with open('hub.html', 'r', encoding='utf-8') as f:
    hub_content = f.read()

# Extract HUB_SEED
match = re.search(r'const HUB_SEED = (\{.*?\n    \});', hub_content, re.DOTALL | re.MULTILINE)
if not match:
    print("Could not find HUB_SEED in hub.html")
    exit(1)

hub_seed = match.group(1)

with open('admin-hub.html', 'r', encoding='utf-8') as f:
    admin_content = f.read()

# Replace SEED
new_admin_content = re.sub(r'const SEED = \{.*?\n      \};', f'const SEED = {hub_seed};', admin_content, flags=re.DOTALL | re.MULTILINE)

with open('admin-hub.html', 'w', encoding='utf-8') as f:
    f.write(new_admin_content)

print("Updated SEED successfully.")
