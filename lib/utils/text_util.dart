String lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do .';
String wordDesc =
    'Sharpen your listening with an extensive collection of diverse words';
String soundDesc =
    'Discover and recognize a wide range of sounds, from urban buzz to tranquil nature';
String speechDesc =
    'Refine your listening by hearing sentences and repeating them back';
String customDesc =
    'Personalize your auditory learning by creating your own modules';
String musicDesc =
    'Tune your ear to musical patterns and pitch variations, mastering melody and tone recognition';
String getPrompt(int wordsNeeded, String wordInput) {
  /* String prompt = 
    """
    Your task involves creating rehabilitation content modules for individuals with cochlear implants. The output format must strictly adhere to the provided structure. Ensure there is no deviation from this format, as consistency is key.

    Examples to demonstrate the required format:

    Input: Tin Tim
    Expected Output: 
    Teeth
    Grim

    Input: Patch
    Expected Output: 
    Latch
    Match
    Catch

    Input: Brag Stag Drag
    Expected Output: 
    Flag

    Now, for the provided input word(s), you are to generate exactly $wordsNeeded distinct words. Each word must be completely unique and not replicate the other generated words.

    1. Ensure each generated word is on a new line
    2. Each word in your output is distinct and does not repeat any of the other generated words.
    3. The words generated are audibly different (for example too and two is not allowed because it sounds the exact same)

    Inputted word(s) for context (Do not repeat these words, but generate $wordsNeeded distinct words):
    $wordInput

    Note: Strictly maintain the format with each word being on a new line, ensuring all $wordsNeeded words are unique and different from the input.
    """;

  return prompt;*/
  /* String prompt = 
  """
  Create exactly $wordsNeeded unique words for a cochlear implant rehabilitation module. Each word must be:

  1. Audibly distinct: Avoid homophones (e.g., 'too' and 'two' should not both appear).
  2. Not a repetition of any other generated word or the input words.
  3. Similar to at least one of the words given.
  4. Listed on a new line.
  5. NOT A REPETITION OF INPUT WORDS OR GENERATED WORDS.

  Input Words: $wordInput

  Example:

  Input: Tin Tim
  Output: 
  Teeth
  Ten
  
  Input: Patch
  Expected Output: 
  Latch
  Poach
  Match

  Input: Brag Boat Drag
  Expected Output: 
  Float

  No matter what, always generate $wordsNeeded word(s), even if the inputted words don't sound similar.
  Your Output:
  """;

  return prompt;

}*/

  String prompt = """
  Generate exactly $wordsNeeded unique words. Each generated word must meet these properties:

  1. Audibly distinct: Avoid homophones (e.g., 'too' and 'two' should not both appear).
  2. NEVER BE a repetition of any other generated word or the input words.
  3. Sound similar to at least one of the words given (rhyming and/or start with the same letter).
  4. Listed on a new line break.
  5. NOT A REPETITION OF INPUT WORDS OR GENERATED WORDS.
  6. Be the same number of syllables as at least one of the input words.

  Input Words: $wordInput

  Here are some examples of valid inputs:

  Input Words: Tin Tim
  Generated Words: 
  Teeth
  Ten
  
  Input Words: Patch
  Generated Words: 
  Latch
  Poach
  Match

  Input Words: Brag Boat Drag
  Generated Words: 
  Float

  No matter what, always generate $wordsNeeded word(s), even if the inputted words don't sound similar.
  REMINDER: Generated Words are not REPETITIONS of input words or generated words.
  Your Output:
  """;

  return prompt;
}

String stripNonAlphaCharacters(String input) {
  // Regular expression pattern to match any non-alphabetic character and non-space character
  final RegExp nonAlphaNonSpacePattern = RegExp(r'[^a-zA-Z ]');

  // Replace all non-alphabetic and non-space characters with an empty string
  return input.replaceAll(nonAlphaNonSpacePattern, '');
}

String capitalizeWord(String word) {
  if (word.isEmpty) return "";
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}