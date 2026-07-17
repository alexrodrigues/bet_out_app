/// Shared string / formatting helpers.
class StringUtils {
  StringUtils._();

  static bool isNullOrEmpty(String? value) =>
      value == null || value.trim().isEmpty;
}
