String pluralize(int num) {
  double preLastDigit = num % 100 / 10;
  if (preLastDigit.round() == 1) {
    return "дней";
  }
  switch (num % 10) {
    case 1:
      return "день";
    case 2:
    case 3:
    case 4:
      return "дня";
    default:
      return "дней";
  }
}