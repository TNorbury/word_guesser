import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:word_guesser/models/char_guess.dart';
import 'package:word_guesser/models/word_guess.dart';

const int kMaxChars = 5;
const int kMaxGuesses = 6;

void main() {
  runApp(const MyApp());
}

String getWord() {
  final allWords = List.from(all)..shuffle();

  final word = allWords.firstWhere((element) => element.length == kMaxChars);
  return word;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Word Guess',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String wordToGuess;

  List<String?> _enteredChars = List.filled(kMaxChars, null);

  List<WordGuess?> _guesses = List.filled(kMaxGuesses, null);

  int _guessNum = 0;

  @override
  void initState() {
    super.initState();
    setUp();
  }

  void setUp() {
    setState(() {
      _enteredChars = List.filled(kMaxChars, null);
      _guesses = List.filled(kMaxGuesses, null);
      _guessNum = 0;
      wordToGuess = getWord();
      debugPrint(wordToGuess);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        int firstNullChar =
            _enteredChars.indexWhere((element) => element == null);
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          // submit guess
          if (firstNullChar == -1) {
            int firstNullGuess =
                _guesses.indexWhere((element) => element == null);

            List<CharGuess> charGuesses = [];

            for (int i = 0; i < _enteredChars.length; i++) {
              String char = _enteredChars[i]!;
              int charIndexInWord = wordToGuess.indexOf(char);

              CharGuessState guessResult;

              if (charIndexInWord == i) {
                guessResult = CharGuessState.correct;
              } else if (charIndexInWord != -1) {
                guessResult = CharGuessState.wrongSpot;
              } else {
                guessResult = CharGuessState.wrong;

                // TODO: track wrong chars
              }

              charGuesses.add(CharGuess(char: char, guessState: guessResult));
            }

            setState(() {
              _guesses[firstNullGuess] = WordGuess(
                chars: charGuesses,
              );
              _guessNum++;

              _enteredChars = List.filled(kMaxChars, null);
            });
            return KeyEventResult.handled;
          }
        }

        // event.

        else if (event.logicalKey == LogicalKeyboardKey.backspace &&
            firstNullChar != 0) {
          int lastChar =
              _enteredChars.lastIndexWhere((element) => element != null);

          setState(() {
            _enteredChars[lastChar] = null;
          });
          return KeyEventResult.handled;
        } else if (event.character == null ||
            (event.character != null &&
                !RegExp(r'[a-z]', caseSensitive: false)
                    .hasMatch(event.character!)) ||
            firstNullChar == kMaxChars ||
            firstNullChar == -1) {
          return KeyEventResult.ignored;
        }

        setState(() {
          _enteredChars[firstNullChar] = event.character;
        });

        return KeyEventResult.handled;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < kMaxGuesses; i++)
                if (i == _guessNum)
                  _GuessRow(
                    enteredChars: _enteredChars,
                  )
                else if (i > _guessNum)
                  _GuessRow(
                    enteredChars: List.filled(kMaxChars, null),
                  )
                else if (i < _guessNum)
                  _ResultRow(
                    wordGuess: _guesses[i]!,
                  ),
              if (_guessNum == kMaxGuesses)
                IconButton(
                  onPressed: () {
                    setUp();
                  },
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuessRow extends StatelessWidget {
  final List<String?> enteredChars;
  const _GuessRow({
    Key? key,
    required this.enteredChars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final char in enteredChars)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: _CharMarker(
              char: char,
            ),
          ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final WordGuess wordGuess;
  const _ResultRow({
    Key? key,
    required this.wordGuess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final char in wordGuess.chars)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: _CharMarker(char: char.char, guessState: char.guessState),
          ),
      ],
    );
  }
}

class _CharMarker extends StatelessWidget {
  final String? char;
  final CharGuessState? guessState;
  const _CharMarker({
    Key? key,
    required this.char,
    this.guessState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = (char ?? " ").toUpperCase();
    Color background = Colors.blue;

    if (guessState != null) {
      switch (guessState!) {
        case CharGuessState.wrong:
          background = Colors.red;
          break;
        case CharGuessState.wrongSpot:
          background = const Color.fromARGB(255, 216, 195, 3);
          break;
        case CharGuessState.correct:
          background = Colors.green;
          break;
      }
    }

    return Container(
      // width: 25,
      // height: 25,
      padding: const EdgeInsets.all(12),
      color: background,
      alignment: Alignment.center,

      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          color: Colors.white,
          fontFeatures: const [
            FontFeature.tabularFigures(),
          ],
        ),
      ),
    );
  }
}
