import 'dart:async';
import 'dart:collection';
import 'dart:ui';

List<String> exitText = ["Let's call it a day 😌", "Leaving already? 🤔", "That's a wrap! 💪", 
                          "Goodbye 👋", "Goodjob 🙌", "Work done ✅"];
String currentFolder = 'Notes';
StreamController<String> folderStream = StreamController.broadcast();

//settings vars
bool stayOnTop = true;
bool askBeforeDeleting = true;

Color dymnomz = const Color(0xFF0BFF00); // Easter Egg :p
Color selectionColor = const Color.fromARGB(140, 228, 250, 255);
Color defaultGray = const Color.fromARGB(255, 201, 201, 201);

String basePath = '';

enum ColorSelectionType {
  font, bar, body
}

final Set<String> supportedLangs = HashSet<String>.from(const <String>[
  'af', // Afrikaans
  'ar', // Arabic
  'az', // Azerbaijani
  'be', // Belarusian
  'bg', // Bulgarian
  'bo', // Tibetan
  'bs', // Bosnian
  'cs', // Czech
  'cy', // Welsh
  'da', // Danish
  'de', // German
  'el', // Modern Greek
  'en', // English
  'es', // Spanish Castilian
  'et', // Estonian
  'eu', // Basque
  'fa', // Persian
  'fi', // Finnish
  'fil', // Filipino Pilipino
  'fr', // French
  'ga', // Irish
  'gl', // Galician
  'gsw', // Swiss German Alemannic Alsatian
  'he', // Hebrew
  'hi', // Hindi
  'hr', // Croatian
  'hu', // Hungarian
  'hy', // Armenian
  'id', // Indonesian
  'is', // Icelandic
  'it', // Italian
  'ja', // Japanese
  'ka', // Georgian
  'ko', // Korean
  'lo', // Lao
  'lt', // Lithuanian
  'lv', // Latvian
  'mk', // Macedonian
  'ml', // Malayalam
  'mn', // Mongolian
  'ms', // Malay
  'my', // Burmese
  'nb', // Norwegian Bokmål
  'ne', // Nepali
  'nl', // Dutch Flemish
  'no', // Norwegian
  'pa', // Panjabi Punjabi
  'pl', // Polish
  'pt', // Portuguese
  'ro', // Romanian Moldavian Moldovan
  'ru', // Russian
  'sk', // Slovak
  'sl', // Slovenian
  'sq', // Albanian
  'sr', // Serbian
  'sv', // Swedish
  'th', // Thai
  'tl', // Tagalog
  'tr', // Turkish
  'uk', // Ukrainian
  'vi', // Vietnamese
  'zh', // Chinese
]);