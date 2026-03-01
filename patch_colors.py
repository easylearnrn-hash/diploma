import re

def rewrite_css(filepath, btn_class):
    with open(filepath, "r") as f:
        content = f.read()

    # The goal is to enforce the border and shadows for all three glow states cleanly
    
    css_to_find = f"""\.{btn_class}\.unpaid-glow\.active {{
      background: rgba\(201,168,76,0\.15\);
      border-color: rgba\(201,168,76,0\.4\);
      color: var\(--gold-primary\);
      box-shadow: none;
    }}"""

    # We just want to find block of unpaid-glow down to the end of paid-glow.active
    # Since regex is finicky across multiline, let's target by string replacement.
    
    # We will search for a generic marker
    target_start = f".{btn_class}.unpaid-glow {{"
    
    # Let's read all lines
    lines = content.split('\n')
    new_lines = []
    in_block = False
    
    for line in lines:
        if f".{btn_class}.unpaid-glow {{" in line:
            in_block = True
            new_lines.append(f"    .{btn_class}.unpaid-glow {{")
            new_lines.append("      border: 1px solid rgba(239, 68, 68, 0.5) !important;")
            new_lines.append("      box-shadow: inset 0 0 10px rgba(239, 68, 68, 0.2) !important;")
            new_lines.append("      color: #ef4444;")
            new_lines.append("    }")
            new_lines.append("")
            new_lines.append(f"    .{btn_class}.unpaid-glow.active, .{btn_class}.unpaid-glow:hover {{")
            new_lines.append("      background: rgba(201,168,76,0.15) !important;")
            new_lines.append("      border-color: rgba(201,168,76,0.4) !important;")
            new_lines.append("      color: var(--gold-primary) !important;")
            new_lines.append("      box-shadow: none !important;")
            new_lines.append("    }")
            new_lines.append("")
            
            new_lines.append(f"    .{btn_class}.partial-glow {{")
            new_lines.append("      border: 1px solid rgba(245, 158, 11, 0.5) !important;")
            new_lines.append("      box-shadow: inset 0 0 10px rgba(245, 158, 11, 0.2) !important;")
            new_lines.append("      color: #f59e0b;")
            new_lines.append("    }")
            new_lines.append("")
            new_lines.append(f"    .{btn_class}.partial-glow.active, .{btn_class}.partial-glow:hover {{")
            new_lines.append("      background: rgba(201,168,76,0.15) !important;")
            new_lines.append("      border-color: rgba(201,168,76,0.4) !important;")
            new_lines.append("      color: var(--gold-primary) !important;")
            new_lines.append("      box-shadow: none !important;")
            new_lines.append("    }")
            new_lines.append("")
            
            new_lines.append(f"    .{btn_class}.paid-glow {{")
            new_lines.append("      border: 1px solid rgba(34, 197, 94, 0.5) !important;")
            new_lines.append("      box-shadow: inset 0 0 10px rgba(34, 197, 94, 0.2) !important;")
            new_lines.append("      color: #22c55e;")
            new_lines.append("    }")
            new_lines.append("")
            new_lines.append(f"    .{btn_class}.paid-glow.active, .{btn_class}.paid-glow:hover {{")
            new_lines.append("      background: rgba(201,168,76,0.15) !important;")
            new_lines.append("      border-color: rgba(201,168,76,0.4) !important;")
            new_lines.append("      color: var(--gold-primary) !important;")
            new_lines.append("      box-shadow: none !important;")
            new_lines.append("    }")
            continue
            
        if in_block:
            # We skip lines until we see the next standard CSS block that ISN'T a glow state
            if line.strip() == "}":
                # Check next line or so
                pass
            if "." in line and "{" in line and "glow" not in line:
                in_block = False
                new_lines.append(line)
            continue
            
        if not in_block:
            new_lines.append(line)

    with open(filepath, "w") as f:
        f.write("\n".join(new_lines))

rewrite_css("admin-payments.html", "reminder-var-btn")
rewrite_css("invoice.html", "inv-reminder-var-btn")
print("CSS patched.")
