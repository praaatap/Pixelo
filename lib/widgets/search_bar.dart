import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onCancel;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
    this.onCancel,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(
        16,
        _isActive ? 12 : 8,
        16,
        _isActive ? 12 : 8,
      ),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isActive
                ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              CupertinoIcons.search,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  widget.onSearch(value);
                  setState(() => _isActive = value.isNotEmpty);
                },
                onTap: () => setState(() => _isActive = true),
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                ),
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
            if (_isActive)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onSearch('');
                  widget.onCancel?.call();
                  setState(() => _isActive = false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
