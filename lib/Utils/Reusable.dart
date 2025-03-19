import 'package:flutter/material.dart';

Padding reusableTextField(String text, bool isPasswordType, TextEditingController controller, FormFieldValidator<String> validator) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordType,
        enableSuggestions: !isPasswordType,
        autocorrect: !isPasswordType,
        validator: validator,
        decoration: InputDecoration(
          labelText: text,
          filled: false,
          floatingLabelBehavior: FloatingLabelBehavior.never
        ),
        keyboardType: isPasswordType? TextInputType.visiblePassword : TextInputType.emailAddress,
      ),
  );
}