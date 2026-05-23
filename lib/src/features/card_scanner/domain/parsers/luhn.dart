bool isValidCard(String cardNumber) {
  final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 13 || digits.length > 19) return false;

  var sum = 0;
  var shouldDouble = false;

  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - 0x30;
    if (shouldDouble) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    shouldDouble = !shouldDouble;
  }
  return sum % 10 == 0;
}
