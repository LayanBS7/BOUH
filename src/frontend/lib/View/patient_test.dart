import 'package:flutter/material.dart';
import '../services/api/patient_service.dart';
import '../../dto/patient_dto.dart';

class PatientTestPage extends StatefulWidget {
  const PatientTestPage({super.key});

  @override
  State<PatientTestPage> createState() => _PatientTestPageState();
}

class _PatientTestPageState extends State<PatientTestPage> {
  final PatientService _service = PatientService();

  final _nameController = TextEditingController(text: "Ali");
  final _ageController = TextEditingController(text: "10");

  String _status = "";
  List<PatientDto> _patients = [];

  Future<void> _loadPatients() async {
    setState(() => _status = "Loading patients...");
    try {
      final list = await _service.getAllPatients();
      setState(() {
        _patients = list;
        _status = "✅ Loaded ${list.length} patients";
      });
    } catch (e) {
      setState(() => _status = "❌ $e");
    }
  }

  Future<void> _createPatient() async {
    setState(() => _status = "Creating patient...");
    try {
      final age = int.parse(_ageController.text.trim());
      final p = PatientDto(name: _nameController.text.trim(), age: age);
      final created = await _service.createPatient(p);

      setState(
        () => _status = "✅ Created: ${created.id ?? ''} ${created.name}",
      );
      await _loadPatients();
    } catch (e) {
      setState(() => _status = "❌ $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient API Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createPatient,
                    child: const Text("POST Create"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loadPatients,
                    child: const Text("GET All"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_status),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, i) {
                  final p = _patients[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text("age: ${p.age}  id: ${p.id ?? '-'}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
