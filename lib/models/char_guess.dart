enum CharGuessState {
  /// incorrect guess
  wrong,

  /// correct letter, but in wrong spot
  wrongSpot,

  /// correct letter, correct spot
  correct,
}

class CharGuess {
  final String char;

  final CharGuessState guessState;

  CharGuess({
    required this.char,
    required this.guessState,
  });
}
