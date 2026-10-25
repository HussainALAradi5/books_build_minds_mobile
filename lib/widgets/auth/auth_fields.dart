import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../enums/auth/auth_mode.dart';
import '../../utils/auth/mobile_number.dart';
import '../../utils/forms/non_negative_number_formatter.dart';

class AuthFields extends StatefulWidget {
  const AuthFields({
    super.key,
    required this.mode,
    required this.codeSent,
    required this.identifier,
    required this.userName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.code,
  });

  final AuthMode mode;
  final bool codeSent;
  final TextEditingController identifier;
  final TextEditingController userName;
  final TextEditingController email;
  final TextEditingController mobileNumber;
  final TextEditingController password;
  final TextEditingController code;

  @override
  State<AuthFields> createState() => _AuthFieldsState();
}

class _AuthFieldsState extends State<AuthFields> {
  bool hidden = true;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (widget.mode == AuthMode.register) ...[
        TextFormField(
          controller: widget.userName,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: _required,
        ),
        const SizedBox(height: 13),
        TextFormField(
          controller: widget.email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          validator: _required,
        ),
        const SizedBox(height: 13),
        TextFormField(
          controller: widget.mobileNumber,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile number (optional)',
            hintText: '+97312345678',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: optionalMobileError,
        ),
        const SizedBox(height: 13),
      ] else ...[
        TextFormField(
          controller: widget.identifier,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email, username or mobile number',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: _required,
        ),
        const SizedBox(height: 13),
      ],
      if (widget.mode == AuthMode.recover && widget.codeSent) ...[
        TextFormField(
          controller: widget.code,
          keyboardType: TextInputType.number,
          inputFormatters: [
            NonNegativeNumberFormatter(),
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(
            labelText: 'Six-digit code',
            prefixIcon: Icon(Icons.password_rounded),
          ),
          validator: (value) =>
              value?.length == 6 ? null : 'Enter the six-digit code',
        ),
        const SizedBox(height: 13),
      ],
      if (widget.mode != AuthMode.recover || widget.codeSent) ...[
        TextFormField(
          controller: widget.password,
          obscureText: hidden,
          decoration: InputDecoration(
            labelText: widget.mode == AuthMode.recover
                ? 'New password'
                : 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () => setState(() => hidden = !hidden),
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: _required,
        ),
        const SizedBox(height: 8),
        if (widget.mode != AuthMode.signIn)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'At least 5 letters and 3 numbers.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    ],
  );
}
