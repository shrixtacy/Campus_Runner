import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/campus_model.dart';
import '../../../logic/campus_provider.dart';

class CampusesScreen extends ConsumerWidget {
  const CampusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusesAsync = ref.watch(campusesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campuses')),
      body: campusesAsync.when(
        data: (campuses) {
          if (campuses.isEmpty) {
            return const Center(child: Text('No campuses found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: campuses.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final campus = campuses[index];
              return ListTile(
                title: Text(campus.name),
                subtitle: Text('${campus.city}, ${campus.state}'),
                leading: const Icon(Icons.school),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCampus(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Campus'),
      ),
    );
  }

  void _openAddCampus(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Campus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Campus name'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final city = cityController.text.trim();
                  final state = stateController.text.trim();

                  if (name.isEmpty || city.isEmpty || state.isEmpty) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final campus = CampusModel(
                    id: '',
                    name: name,
                    city: city,
                    state: state,
                  );

                  await ref.read(campusRepositoryProvider).addCampus(campus);

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
