String? Function(String?) numberField(String fieldName) {
  return (value) {
    final val = value?.replaceAll(',', '.') ?? '';

    if (val.trim().isNotEmpty && double.tryParse(val) == null) {
      return '$fieldName must be a number';
    }
    return null;
  };
}

String? Function(String?) wholeNumberField(String fieldName) {
  return (value) {
    final val = value?.replaceAll(',', '') ?? '';

    if (val.trim().isNotEmpty && int.tryParse(val) == null) {
      return '$fieldName must be a whole number in this field.';
    }
    return null;
  };
}

String? Function(String?) requiredField(String fieldName) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  };
}

String? Function(String?) walletAddres() {
  return (value) {
    if (value != null &&
        (value.trim().length < 32 || value.trim().length > 44)) {
      return 'Wallet address is not valid';
    }
    return null;
  };
}

String? Function(String?) max(double max) {
  return (value) {
    if (value != null &&
        double.tryParse(value) != null &&
        double.tryParse(value)! > max) {
      return 'Value must be not greater than $max';
    }
    return null;
  };
}

String? Function(String?) min(double min, {String? errorText}) {
  return (value) {
    if (value != null &&
        double.tryParse(value) != null &&
        double.tryParse(value)! < min) {
      return 'Value must be not less than $min';
    }
    return null;
  };
}

String? Function(String?) minInt(int min, {String? errorText}) {
  return (value) {
    if (value != null &&
        int.tryParse(value) != null &&
        int.tryParse(value)! < min) {
      return errorText ?? 'Value must be not less than $min';
    }
    return null;
  };
}

String? Function(String?) multiValidate(
  List<String? Function(String?)> validators,
) {
  return (value) {
    String? message;

    for (var validator in validators) {
      message = validator(value);
      if (message != null) {
        break;
      }
    }

    return message;
  };
}
