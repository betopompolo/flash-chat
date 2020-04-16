class TextFormFieldValidator {
  static empty(String message) =>
          (String value) => value.isEmpty ? message : null;

  static final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static email(String message) =>
          (String value) => _emailRegex.hasMatch(value) ? null : message;
}