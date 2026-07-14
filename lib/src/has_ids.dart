mixin HasIds {
  Set<String> getAllIds();

  static String generateUniqueId(HasIds hasIds, {String? prefix}) {
    String out = prefix ?? "";
    int suffix = 0;
    Set<String> used = hasIds.getAllIds();
    while (used.contains(out)) {
      suffix++;
      out = "${(prefix ?? "")}$suffix";
    }
    return out;
  }
}
