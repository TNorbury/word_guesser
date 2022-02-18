import 'package:word_guesser/models/char_guess.dart';

import '../main.dart';

class WordGuess {
  final List<CharGuess> chars;
  WordGuess({
    required this.chars,
  }) : assert(chars.length == kMaxChars);
}
