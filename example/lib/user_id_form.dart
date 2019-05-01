import 'package:flutter/material.dart';

class UserIdForm extends StatefulWidget {
  const UserIdForm(this.onChanged);

  final ValueChanged<String> onChanged;

  @override
  _UserIdFormState createState() => _UserIdFormState();
}

class _UserIdFormState extends State<UserIdForm> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            labelText: 'User Id'),
        onChanged: widget.onChanged);
  }
}
