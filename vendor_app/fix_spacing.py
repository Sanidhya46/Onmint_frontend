import re

file_path = r"c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\lib\screens\auth\register_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# The user wants less spacing before the "SUBMIT FOR VERIFICATION" button.
# Looking at _buildPharmacistStep3 and _buildBloodBankStep3, there's `const SizedBox(height: 24)` before the secure container
content = re.sub(r"const SizedBox\(height:\s*24\),\s*Container\(\s*(?:decoration:|padding:).*?securely stored.*?\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*Container\(\s*padding:\s*const\s*EdgeInsets\.all\(20\)", 
lambda m: m.group(0).replace("const SizedBox(height: 24)", "const SizedBox(height: 8)").replace("EdgeInsets.all(20)", "EdgeInsets.symmetric(horizontal: 20, vertical: 8)"), 
content, flags=re.DOTALL)

# Let's just do a simpler replace.
content = content.replace("const SizedBox(height: 24),\n                    Container(\n                      decoration: BoxDecoration(\n                          color: Colors.blue.shade50,",
"const SizedBox(height: 12),\n                    Container(\n                      decoration: BoxDecoration(\n                          color: Colors.blue.shade50,")

content = content.replace("const SizedBox(height: 24),\n                    Container(\n                      padding: const EdgeInsets.all(16),\n                      decoration: BoxDecoration(\n                        color: Colors.blue.shade50.withOpacity(0.5),",
"const SizedBox(height: 12),\n                    Container(\n                      padding: const EdgeInsets.all(16),\n                      decoration: BoxDecoration(\n                        color: Colors.blue.shade50.withOpacity(0.5),")

# And for the button container:
content = content.replace("Container(\n              padding: const EdgeInsets.all(20),\n              decoration: const BoxDecoration(\n                color: Colors.white,\n                boxShadow: [\n                  BoxShadow(\n                      color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)\n                ],\n              ),\n              child: ElevatedButton(\n                onPressed: _isLoading ? null : _submit,",
"Container(\n              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),\n              decoration: const BoxDecoration(\n                color: Colors.white,\n              ),\n              child: ElevatedButton(\n                onPressed: _isLoading ? null : _submit,")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Spacing fixed")
