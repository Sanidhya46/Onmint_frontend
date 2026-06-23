import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final IconData? icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.value,
    required this.hint,
    this.icon,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.hasError ? Colors.red.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: widget.value ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.items;
                  }
                  return widget.items.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  state.didChange(selection);
                  widget.onChanged(selection);
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  // Listen to changes to ensure manual input also updates the state
                  // but typically we only want exact matches. We'll let them type freely but onChanged is called on selected.
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      icon: widget.icon != null ? Icon(widget.icon, color: const Color(0xFF0D6EFD), size: 18) : null,
                      hintText: widget.hint,
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    onChanged: (val) {
                      state.didChange(val);
                      widget.onChanged(val);
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        width: MediaQuery.of(context).size.width * 0.8, // Fallback width
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(option, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                  ),
                                );
                              },
                            );
                          }
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(state.errorText ?? '',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 10)),
              ),
          ],
        );
      },
    );
  }
}
