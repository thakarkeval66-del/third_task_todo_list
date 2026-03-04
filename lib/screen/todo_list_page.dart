import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../provider/todo_provider.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/todo_form.dart';
import 'details_page.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth Todos'),
        elevation: 0,
      ),
      body: Column(
        children: [
          const CustomSearchBar(),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final todos = provider.todos;
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos found. Add one!'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(todo: todo),
                            ),
                          );
                        },
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: todo.status == TodoStatus.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(todo.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _StatusBadge(status: todo.status),
                                const SizedBox(width: 8),
                                Text(
                                  'Timer: ${_formatTime(todo.remainingSeconds)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (todo.status != TodoStatus.done) ...[
                              IconButton(
                                icon: Icon(
                                  todo.status == TodoStatus.inProgress
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: todo.status == TodoStatus.inProgress
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                onPressed: () => provider.toggleStatus(todo),
                                tooltip: todo.status == TodoStatus.inProgress ? 'Pause' : 'Start',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.blue),
                                onPressed: () => provider.markAsDone(todo),
                                tooltip: 'Finish',
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => provider.deleteTodo(todo.id),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const TodoForm(),
          );
        },
        label: const Text('Add Todo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TodoStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TodoStatus.todo:
        color = Colors.blue;
        label = 'TODO';
        break;
      case TodoStatus.inProgress:
        color = Colors.orange;
        label = 'In-Progress';
        break;
      case TodoStatus.done:
        color = Colors.green;
        label = 'Done';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
