import 'package:amplitude_flutter/amplitude_flutter.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';

class GroupIdentifyForm extends StatefulWidget {
  @override
  _GroupIdentifyFormState createState() => _GroupIdentifyFormState();
}

class _GroupIdentifyFormState extends State<GroupIdentifyForm> {
  void onPress() {
    if (groupType.text.isNotEmpty &&
        groupValue.text.isNotEmpty &&
        groupPropertyKey.text.isNotEmpty &&
        groupPropertyValue.text.isNotEmpty) {
      final Identify identify = Identify()
        ..set(groupPropertyKey.text, groupPropertyValue.text);

      AppState.of(context)
        ..analytics.groupIdentify(groupType.text, groupValue.text, identify)
        ..setMessage('Group Identify sent.');
    }
  }

  final TextEditingController groupType =
      TextEditingController(text: 'account');
  final TextEditingController groupValue = TextEditingController(text: 'acme');
  final TextEditingController groupPropertyKey =
      TextEditingController(text: '');
  final TextEditingController groupPropertyValue =
      TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    final InputDecoration dec = InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Group Identify',
            textScaleFactor: 1.2,
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(
              child: TextField(
                  controller: groupType,
                  decoration: dec.copyWith(labelText: 'Group Type'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: groupValue,
                  decoration: dec.copyWith(labelText: 'Group Value'))),
        ]),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(
              child: TextField(
            controller: groupPropertyKey,
            decoration: dec.copyWith(labelText: 'User Property Key'),
          )),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
            controller: groupPropertyValue,
            decoration: dec.copyWith(labelText: 'User Property Value'),
          )),
        ]),
        RaisedButton(
            child: const Text('Send Group Identify'), onPressed: onPress)
      ],
    );
  }
}
