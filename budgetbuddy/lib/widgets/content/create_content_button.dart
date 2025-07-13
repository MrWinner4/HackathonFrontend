import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../colorscheme.dart';

class CreateContentButton extends StatefulWidget {
  final void Function(Map<String, dynamic> content, String type)? onCreated;
  const CreateContentButton({Key? key, this.onCreated}) : super(key: key);

  @override
  State<CreateContentButton> createState() => _CreateContentButtonState();
}

class _CreateContentButtonState extends State<CreateContentButton> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  Future<void> _showCreateDialog() async {
    String? selectedType;
    String topic = '';
    _error = null;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Content'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
                      DropdownMenuItem(value: 'episode', child: Text('Episode')),
                    ],
                    onChanged: (val) => setState(() => selectedType = val),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) => topic = val,
                    decoration: const InputDecoration(labelText: 'Topic'),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColorScheme.accentVariant),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (selectedType == null || topic.trim().isEmpty) {
                            setState(() => _error = 'Please select a type and enter a topic.');
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          try {
                            final response = await _apiService.post(
                              selectedType == 'lesson'
                                  ? '/lessons/generate'
                                  : '/stories/generate',
                              data: {'topic': topic.trim(), 'content_type': selectedType},
                            );
                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                              if (widget.onCreated != null) {
                                widget.onCreated!(response.data, selectedType!);
                              }
                            } else {
                              setState(() => _error = 'Failed to create content.');
                            }
                          } catch (e) {
                            setState(() => _error = 'Error: $e');
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColorScheme.accent),
                        )
                      : const Text('Create', style: TextStyle(color: AppColorScheme.onAccent),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _showCreateDialog,
      icon: const Icon(Icons.add),
      label: const Text('Create'),
      backgroundColor: AppColorScheme.accent,
      foregroundColor: AppColorScheme.onAccent,
    );
  }
} 