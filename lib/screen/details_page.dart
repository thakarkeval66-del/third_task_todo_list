import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../provider/todo_provider.dart';
import '../widgets/todo_form.dart';

class DetailsPage extends StatelessWidget {
  final Todo todo;

  const DetailsPage({super.key, required this.todo});

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => TodoForm(todo: todo),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                // Find the latest todo state from provider
                final currentTodo = provider.todos.firstWhere(
                  (t) => t.id == todo.id,
                  orElse: () => todo,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currentTodo.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentTodo.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: currentTodo.totalSeconds > 0
                                  ? currentTodo.remainingSeconds / currentTodo.totalSeconds
                                  : 0,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          Text(
                            _formatTime(currentTodo.remainingSeconds),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  // color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _StatusIndicator(status: currentTodo.status),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ControlButton(
                            icon: currentTodo.status == TodoStatus.inProgress
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            label: currentTodo.status == TodoStatus.inProgress ? 'Pause' : 'Start',
                            onPressed: currentTodo.status == TodoStatus.done
                                ? null
                                : () => provider.toggleStatus(currentTodo),
                            color: currentTodo.status == TodoStatus.inProgress
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 24),
                          _ControlButton(
                            icon: Icons.stop_rounded,
                            label: 'Finish',
                            onPressed: currentTodo.status == TodoStatus.done
                                ? null
                                : () => provider.markAsDone(currentTodo),
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final TodoStatus status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color color;

    switch (status) {
      case TodoStatus.todo:
        label = 'READY TO START';
        icon = Icons.timer_outlined;
        color = Colors.blue;
        break;
      case TodoStatus.inProgress:
        label = 'IN PROGRESS';
        icon = Icons.bolt;
        color = Colors.orange;
        break;
      case TodoStatus.done:
        label = 'COMPLETED';
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.grey : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
