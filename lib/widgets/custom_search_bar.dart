import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/todo_provider.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          context.read<TodoProvider>().setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          // fillColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
