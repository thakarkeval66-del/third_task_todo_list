import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_model.dart';
import '../provider/todo_provider.dart';

class TodoForm extends StatefulWidget {
  final Todo? todo;

  const TodoForm({super.key, this.todo});

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');

    int totalSecs = widget.todo?.totalSeconds ?? 0;
    _minutesController = TextEditingController(text: (totalSecs ~/ 60).toString());
    _secondsController = TextEditingController(text: (totalSecs % 60).toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final mins = int.tryParse(_minutesController.text) ?? 0;
      final secs = int.tryParse(_secondsController.text) ?? 0;
      final totalSeconds = (mins * 60) + secs;

      if (totalSeconds <= 0 || totalSeconds > 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time must be between 1 second and 5 minutes.')),
        );
        return;
      }

      if (widget.todo == null) {
        final newTodo = Todo(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          totalSeconds: totalSeconds,
          remainingSeconds: totalSeconds,
        );
        context.read<TodoProvider>().addTodo(newTodo);
      } else {
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          totalSeconds: totalSeconds,
          remainingSeconds: totalSeconds, // Reset timer on edit as per common pattern
          status: TodoStatus.todo,
          lastStartedAt: null,
        );
        context.read<TodoProvider>().updateTodo(0, updatedTodo); // index is handled inside provider by ID
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.todo == null ? 'Add Todo' : 'Edit Todo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      decoration: const InputDecoration(labelText: 'Min (0-5)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      decoration: const InputDecoration(labelText: 'Sec (0-59)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
