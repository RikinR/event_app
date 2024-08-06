// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:event_app/models/event.dart';
import 'package:event_app/view_models/event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventCreateView extends StatefulWidget {
  const EventCreateView({super.key});

  @override
  State<EventCreateView> createState() => _EventCreateViewState();
}

class _EventCreateViewState extends State<EventCreateView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedTime;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  bool _isCreating = false;

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = _selectedDate ?? now;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _updateDateController();
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay initialTime =
        TimeOfDay.fromDateTime(_selectedTime ?? DateTime.now());

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedDate?.year ?? DateTime.now().year,
          _selectedDate?.month ?? DateTime.now().month,
          _selectedDate?.day ?? DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _updateDateController();
      });
    }
  }

  void _updateDateController() {
    if (_selectedDate != null && _selectedTime != null) {
      _dateController.text = _dateFormat.format(DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ));
    }
  }

  Future<void> _createEvent() async {
    final eventViewModel = context.read<EventViewModel>();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _selectedDate != null && _selectedTime != null) {
      setState(() {
        _isCreating = true;
      });

      Event event = Event(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        date: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        location: _locationController.text,
        creatorId: user.uid,
      );

      try {
        await eventViewModel.createEvent(event);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create event: $e")),
        );
      } finally {
        setState(() {
          _isCreating = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a correct date and time")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isCreating) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Create Event',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titleController, 'Title'),
                  _buildTextField(_descriptionController, 'Description'),
                  _buildTextField(_locationController, 'Location'),
                  _buildDateTimeField(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create Event'),
                  ),
                ],
              ),
            ),
            if (_isCreating)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDateTimeField() {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date and Time',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () {
        _selectDate();
        _selectTime();
      },
    );
  }
}
