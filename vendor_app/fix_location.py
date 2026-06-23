import re

file_path = r"c:\Users\a\Desktop\Updated_Onmint\New_Onmint\vendor_app\lib\screens\auth\register_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Use Current Location button logic
pattern = r"TextButton\.icon\(\s*onPressed:\s*_getCurrentLocation,\s*icon:\s*const\s*Icon\(Icons\.my_location,\s*size:\s*16,\s*color:\s*Color\(0xFF0033CC\)\),\s*label:\s*const\s*Text\(\s*'Use Current Location',\s*(.*?)\s*style:\s*(.*?)\s*\),\s*style:\s*(.*?)\s*\)"

def repl(match):
    extra_label = match.group(1) # overflow: ...
    label_style = match.group(2) # TextStyle(...)
    btn_style = match.group(3)
    
    return f"""TextButton.icon(
                                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                  icon: _isFetchingLocation 
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                      : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                  label: Text(
                                    _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                    {extra_label}
                                    style: const {label_style},
                                  ),
                                  style: {btn_style}
                                )"""

new_content, count = re.subn(pattern, repl, content, flags=re.DOTALL)
print(f"Replaced Use Current Location {count} times.")

# Also fix the spacing in Step 3 for pathology (and others)
# "Your documents are securely stored and used only for verification."
# The user wants "very less space with submit for verification button nd all divs are evenly distributed .. in whole page no unecessary spacing"

with open(file_path, "w", encoding="utf-8") as f:
    f.write(new_content)
