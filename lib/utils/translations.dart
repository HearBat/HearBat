// ignore_for_file: constant_identifier_names

// need this for AppLocale.title.getString(context) and I dont want to import 2 files everywhere we need to translate
export 'package:flutter_localization/flutter_localization.dart';




// for the formatting it would be nice if we could have some standard format maybe
// {page}{some identifier} or {widget}{some identifier}
// just so we kind of know what it is off a first look, and let's try to keep translations together based on where theyre being used

// but also let's not worry TOO much since we are gonna uproot this for UI changes later

mixin AppLocale {
  // Home Page
  static const String homePageTitle       = 'homePageTitle';
  static const String homePageSubtitle    = 'homePageSubtitle';
  static const String homePageWordsTitle  = 'homePageTrainWords';
  static const String homePageSoundsTitle = 'homePageTrainSounds';
  static const String homePageSpeechTitle = 'homePageTrainSpeech';
  static const String homePageMusicTitle  = 'homePageTrainMusic';
  static const String homePageCustomTitle = 'homePageTrainCustom';
  static const String homePageWordsDesc   = 'homePageWordsDesc';
  static const String homePageSoundsDesc  = 'homePageSoundsDesc';
  static const String homePageSpeechDesc  = 'homePageSpeechDesc';
  static const String homePageMusicDesc   = 'homePageMusicDesc';
  static const String homePageCustomDesc  = 'homePageCustomDesc';

  // Sound Adjustments Page
  static const String soundAdjustPageReady = 'soundAdjustPageReady';
  static const String soundAdjustPagePleaseAdjust = 'soundAdjustPagePleaseAdjust';

  // Settings Page
  static const String settingsPageTitle = 'settingsPageTitle';
  static const String settingsPageLanguageTitle = 'settingsPageLanguageTitle';
  static const String settingsPageLanguageEnglish = 'settingsPageLanguageEnglish';

  static const String settingsPageFeedbackTitle = 'settingsPageFeedbackTitle';
  static const String settingsPageFeedbackOn = 'settingsPageFeedbackOn';
  static const String settingsPageFeedbackOff = 'settingsPageFeedbackOff';

  static const String settingsPageVoiceTitle = 'settingsPageVoiceTitle';
  static const String settingsPageVoiceUSFemale = 'settingsPageVoiceUSFemale';
  static const String settingsPageVoiceUSMale = 'settingsPageVoiceUSMale';
  static const String settingsPageVoiceUKFemale = 'settingsPageVoiceUKFemale';
  static const String settingsPageVoiceUKMale = 'settingsPageVoiceUKMale';
  static const String settingsPageVoiceINFemale = 'settingsPageVoiceINFemale';
  static const String settingsPageVoiceINMale = 'settingsPageVoiceINMale';
  static const String settingsPageVoiceAUFemale = 'settingsPageVoiceAUFemale';
  static const String settingsPageVoiceAUMale = 'settingsPageVoiceAUMale';

  static const String settingsPageClearCache = 'settingsPageClearCache';

  // General (Multi-Page) Translations
  static const String generalAccentPreview = 'generalAccentPreview';

  static const Map<String, dynamic> EN = {
    // Home Page
    homePageTitle: 'HearBat',
    homePageSubtitle: 'your hearing companion',
    homePageWordsTitle: 'Train Words',
    homePageSoundsTitle: 'Train Sounds',
    homePageSpeechTitle: 'Train Speech',
    homePageMusicTitle: 'Train Music',
    homePageCustomTitle: 'Custom Module Builder',
    homePageWordsDesc: 'Sharpen your listening with an extensive collection of diverse words',
    homePageSoundsDesc: 'Discover and recognize a wide range of sounds, from urban buzz to tranquil nature',
    homePageSpeechDesc: 'Refine your listening by hearing sentences and repeating them back',
    homePageMusicDesc: 'Tune your ear to musical patterns and pitch variations, mastering melody and tone recognition',
    homePageCustomDesc: 'Personalize your auditory learning by creating your own modules',

    // Sound Adjustments Page
    soundAdjustPageReady: 'Ready',
    soundAdjustPagePleaseAdjust: 'Please adjust your \nsound settings',
    // Insights Page

    // Settings Page
    settingsPageTitle: 'SETTINGS',
    settingsPageLanguageTitle: 'Language',
    settingsPageLanguageEnglish: 'English',

    settingsPageFeedbackTitle: 'Feedback Sound',
    settingsPageFeedbackOn: 'On',
    settingsPageFeedbackOff: 'Off',

    settingsPageVoiceTitle: 'Voice Select',
    settingsPageVoiceUSFemale: 'American Female',
    settingsPageVoiceUSMale: 'American Male',
    settingsPageVoiceUKFemale: 'English Female',
    settingsPageVoiceUKMale: 'English Male',
    settingsPageVoiceINFemale: 'Indian Female',
    settingsPageVoiceINMale: 'Indian Male',
    settingsPageVoiceAUFemale: 'Australian Female',
    settingsPageVoiceAUMale: 'Australian Male',

    settingsPageClearCache: 'CLEAR CACHE',
    //. General (Multi-Page)
    generalAccentPreview: 'Hello this is how I sound'
  };


  // idk some examples of other langs from the package readme
  static const Map<String, dynamic> KM = {homePageWordsTitle: 'ការធ្វើមូលដ្ឋានីយកម្ម'};
  static const Map<String, dynamic> JA = {homePageWordsTitle: 'ローカリゼーション'};
}
