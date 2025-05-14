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

  // Navigation Bar
  static const String navBarHome = 'navBarHome';
  static const String navBarInsights = 'navBarInsights';
  static const String navBarProfile = 'navBarProfile';

  // Sound Adjustments Page
  static const String soundAdjustPageReady = 'soundAdjustPageReady';
  static const String soundAdjustPageSoundCheck: 'soundAdjustPageSoundCheck',
  static const String soundAdjustPagePleaseAdjust = 'soundAdjustPagePleaseAdjust';

  // Settings Page
  static const String settingsPageTitle = 'settingsPageTitle';
  static const String settingsPageLanguageTitle = 'settingsPageLanguageTitle';
  static const String settingsPageLanguageEnglish = 'settingsPageLanguageEnglish';
  static const String settingsPageLanguageVietnamese = 'settingsPageLanguageVietnamese';

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

  // Difficulty Selection Page
  static const String selectionPageDifficultyTitle = 'selectionPageDifficultyTitle';
  static const String selectionPageDifficultySubtitle = 'selectionPageDifficultySubtitle';
  static const String selectionPageDifficultyNormal = 'selectionPageDifficultyNormal';
  static const String selectionPageDifficultyHard = 'selectionPageDifficulty';

  static const String selectionPageVoiceTitle = 'selectionPageVoiceTitle';
  static const String selectionPageVoiceSubtitle = 'selectionPageVoiceSubtitle';
  static const String selectionPageVoiceMale = 'selectionPageVoiceMale';
  static const String selectionPageVoiceFemale = 'selectionPageVoiceFemale';
  static const String selectionPageVoiceRandom = 'selectionPageVoiceRandom';

  static const String selectionPageBackgroundTitle = 'selectionPageBackgroundTitle';
  static const String selectionPageBackgroundSubtitle = 'selectionPageBackgroundSubtitle';
  static const String selectionPageBackgroundNone = 'selectionPageBackgroundNone';
  static const String selectionPageBackgroundRain = 'selectionPageBackgroundRain';
  static const String selectionPageBackgroundCoffee = 'selectionPageBackgroundCoffee';

  static const String selectionPageIntensityTitle = 'selectionPageIntensityTitle';
  static const String selectionPageIntensitySubtitle = 'selectionPageIntensitySubtitle';
  static const String selectionPageIntensityLow = 'selectionPageIntensityLow';
  static const String selectionPageIntensityMedium = 'selectionPageIntensityMedium';
  static const String selectionPageIntensityHigh = 'selectionPageIntensityHigh';

  static const String selectionPageStart = 'selectionPageStart';

  // Insights Page
  static const String insightsPageTitle = 'insightsPageTitle';
  static const String insightsPageToday = 'insightsPageToday';
  static const String insightsPageTimePracticed = 'insightsPageTimePracticed';
  static const String insightsPageMinuteAbbr = 'insightsPageMinuteAbbr';
  static const String insightsPageDailyGoal = 'insightsPageDailyGoal';
  static const String insightsPageSpeechAccuracy = 'insightsPageSpeechAccuracy';
  static const String insightsPageNoiseChallenge = 'insightsPageNoiseChallenge';
  static const String insightsPageMissedWords = 'insightsPageMissedWords';
  static const String insightsPageMissedSounds = 'insightsPageMissedSounds';
  static const String insightsPageSpeechOvertime = 'insightsPageSpeechOvertime';

  // Missed Words Page
  static const String missedWordsPageMostMissedWords = 'missedWordsPageMostMissedWords';

  // Missed Sounds Page
  static const String missedSoundsPageMostMissedSounds = 'missedSoundsPageMostMissedSounds';

  // Word Chapters Page
  static const String wordChaptersPageTitle = 'wordChaptersPageTitle';

  // Sound Chapters Page
  static const String soundChaptersPageTitle = 'soundChaptersPageTitle';

  // Speech Chapters Page
  static const String speechChaptersPageTitle = 'speechChaptersPageTitle';

  // Music Chapters Page
  static const String musicChaptersPageTitle = 'musicChaptersPageTitle';

  // Custom Modules Page
  static const String customModulesPageTitle = 'customModulesPageTitle';
  static const String customModulesPageCreate = 'customModulesPageStart';
  static const String customModulesPageStart = 'customModulesPageCreate';

  // Check Button Widget
  static const String checkButtonWidgetCheck = 'checkButtonWidget';

  // Four Answer Widget
  static const String fourAnswerWidgetPrompt = 'fourAnswerWidgetPrompt';

  // Module Widget
  static const String moduleWidgetWordsMissed = 'moduleWidgetWordsMissed';

  // Pitch Resolution Widget
  static const String pitchResolutionWidgetSoundsMissed = 'pitchResolutionWidgetSoundsMissed';
  static const String pitchResolutionWidgetGreatJob = 'pitchResolutionWidgetGreatJob';
  static const String pitchResolutionWidgetSemitones = 'pitchResolutionWidgetSemitones';
  static const String pitchResolutionWidgetPrompt = 'pitchResolutionWidgetHigherOrLower';
  static const String pitchResolutionWidgetHigher = 'pitchResolutionWidgetHigher';
  static const String pitchResolutionWidgetLower = 'pitchResolutionWidgetLower';

  // Speech Module Widget
  static const String speechModuleWidgetFailedTranscription = 'speechModuleWidgetFailedTranscription';
  static const String speechModuleWidgetPrompt = 'speechModuleWidgetPrompt';
  static const String speechModuleWidgetPlayAudio = 'speechModuleWidgetPlayAudio';
  static const String speechModuleWidgetStopRecording = 'speechModuleWidgetStopRecording';
  static const String speechModuleWidgetStartRecording = 'speechModuleWidgetStartRecording';
  static const String speechModuleWidgetWhatYouSaid = 'speechModuleWidgetWhatYouSaid';
  static const String speechModuleWidgetOriginal = 'speechModuleWidgetOriginal';
  static const String speechModuleWidgetAccuracy = 'speechModuleWidgetAccuracy';
  static const String speechModuleWidgetAverage = 'speechModuleWidgetAverage';
  static const String speechModuleWidgetHighestAverage = 'speechModuleWidgetHighestAverage';

  // Alternating Path Layout Widget
  static const String alternatingPathViewChapterWords = 'alternatingPathViewChapterWords';

  // Animated Button Widget
  static const String animatedButtonWidgetExercise = 'animatedButtonWidgetExercise';
  static const String animatedButtonWidgetChapterName = 'animatedButtonWidgetChapterName';
  static const String animatedButtonWidgetCancel = 'animatedButtonWidgetCancel';
  static const String animatedButtonWidgetStart = 'animatedButtonWidgetStart';

  // Module Card Widget
  static const String moduleCardWidgetHearWords = 'moduleCardWidgetHearWords';

  // Edit Custom Module
  static const String editCustomModuleMaximumOf = 'editCustomModuleMaximumOf';
  static const String editCustomModuleGroupsAllowed = 'editCustomModuleGroupsAllowed';
  static const String editCustomModuleDeleteModule = 'editCustomModuleDeleteModule';
  static const String editCustomModuleDeleteModuleWarning = 'editCustomModuleDeleteModuleWarning';
  static const String editCustomModuleDeleteGroup = 'editCustomModuleDeleteGroup';
  static const String editCustomModuleDeleteGroupWarning = 'editCustomModuleDeleteGroupWarning';
  static const String editCustomModuleGroupDeleted = 'editCustomModuleGroupDeleted';
  static const String editCustomModuleDelete = 'editCustomModuleDelete';
  static const String editCustomModuleGenerationFailed = 'editCustomModuleGenerationFailed';
  static const String editCustomModuleGenerationError = 'editCustomModuleGenerationError';
  static const String editCustomModuleSavedSuccessfully = 'editCustomModuleSavedSuccessfully';
  static const String editCustomModuleNoValidGroups = 'editCustomModuleNoValidGroups';
  static const String editCustomModuleDiscardChanges = 'editCustomModuleDiscardChanges';
  static const String editCustomModuleUnsavedChangesWarning = 'editCustomModuleUnsavedChangesWarning';
  static const String editCustomModuleKeepEditing = 'editCustomModuleKeepEditing';
  static const String editCustomModuleDiscard = 'editCustomModuleDiscard';
  static const String editCustomModuleNoGroupsFound = 'editCustomModuleNoGroupsFound';
  static const String editCustomModuleAddSet = 'editCustomModuleAddSet';
  static const String editCustomModuleSave = 'editCustomModuleSave';
  static const String editCustomModuleSet = 'editCustomModuleSet';

  static const String customUtilAlreadyExists = 'customUtilAlreadyExists';
  static const String customUtilOverwritePrompt = 'customUtilOverwritePrompt';
  static const String customUtilReturnToModule = 'customUtilReturnToModule';
  static const String customUtilOverwrite = 'customUtilOverwrite';
  static const String customUtilTitle = 'customUtilTitle';
  static const String customUtilEntryPrompt = 'customUtilEntryPrompt';
  static const String customUtilFillTheRest = 'customUtilFillTheRest';
  static const String customUtilModuleName = 'customUtilModuleName';
  static const String customUtilSaveModule = 'customUtilSaveModule';

  // General (Multi-Page) Translations
  static const String generalAccentPreview = 'generalAccentPreview';
  static const String generalCancel = 'generalCancel';
  static const String generalLoading = 'generalLoading';
  static const String generalContinue = 'generalContinue';
  static const String generalYouChose = 'moduleWidgetYouChose';
  static const String generalCorrectAnswer = 'moduleWidgetCorrectAnswer';
  static const String generalLessonComplete = 'moduleWidgetLessonComplete';
  static const String generalScore = 'moduleWidgetScore';
  static const String generalHighestScore = 'moduleWidgetHighestScore';
  static const String generalCorrect = 'generalCorrect';
  static const String generalIncorrect = 'generalIncorrect';
  static const String generalGreat = 'generalGreat';

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

    // Navigation Bar
    navBarHome: 'Home',
    navBarInsights: 'Insights',
    navBarProfile: 'Profile',

    // Sound Adjustments Page
    soundAdjustPageReady: 'Ready',
    soundAdjustPageSoundCheck: 'Sound Check!\n',
    soundAdjustPagePleaseAdjust: 'Adjust your volume until you can\ncomfortably hear the music',

    // Settings Page
    settingsPageTitle: 'SETTINGS',
    settingsPageLanguageTitle: 'Language',
    settingsPageLanguageEnglish: 'English',
    settingsPageLanguageVietnamese: 'Test Language Switch (off)',

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

    // Difficulty Selection Page
    selectionPageDifficultyTitle: 'Difficulty',
    selectionPageDifficultySubtitle: 'By completing modules, you can unlock difficulty levels',
    selectionPageDifficultyNormal: 'Normal',
    selectionPageDifficultyHard: 'Hard',

    selectionPageVoiceTitle: 'Voice Type',
    selectionPageVoiceSubtitle: 'Random swaps between male and female',
    selectionPageVoiceFemale: 'Female',
    selectionPageVoiceMale: 'Male',
    selectionPageVoiceRandom: 'Random',

    selectionPageBackgroundTitle: 'Background Noise',
    selectionPageBackgroundSubtitle: 'Background noises to add an extra challenge',
    selectionPageBackgroundNone: 'None',
    selectionPageBackgroundRain: 'Rain',
    selectionPageBackgroundCoffee: 'Coffee Shop',

    selectionPageIntensityTitle: 'Noise Intensity',
    selectionPageIntensitySubtitle: 'Choose the intensity of background noises',
    selectionPageIntensityLow: 'Low',
    selectionPageIntensityMedium: 'Medium',
    selectionPageIntensityHigh: 'High',

    selectionPageStart: 'START EXERCISE',

    // Insights Page
    insightsPageTitle: 'INSIGHTS',
    insightsPageToday: 'Today',
    insightsPageTimePracticed: 'Time practiced',
    insightsPageMinuteAbbr: 'm',
    insightsPageDailyGoal: 'of daily goal achieved',
    insightsPageSpeechAccuracy: 'Speech Accuracy',
    insightsPageNoiseChallenge: 'Noise Challenge',
    insightsPageMissedWords: 'View Most Missed Words',
    insightsPageMissedSounds: 'View Most Missed Sounds',
    insightsPageSpeechOvertime: 'Speech Overtime',

    // Missed Words Page
    missedWordsPageMostMissedWords: 'Most Missed Words',

    // Missed Sounds Page
    missedSoundsPageMostMissedSounds: 'Most Missed Sounds',

    // Word Chapters Page
    wordChaptersPageTitle: 'WORD',

    // Sound Chapters Page
    soundChaptersPageTitle: 'SOUND',

    // Speech Chapters Page
    speechChaptersPageTitle: 'SPEECH',

    // Music Chapters Page
    musicChaptersPageTitle: 'MUSIC',

    // Custom Modules Page
    customModulesPageTitle: 'Custom Module Builder',
    customModulesPageCreate: 'Create Module',
    customModulesPageStart: 'START',

    // Check Button Widget
    checkButtonWidgetCheck: 'CHECK',

    // Four Answer Widget
    fourAnswerWidgetPrompt: 'What do you hear?',

    // Module Widget
    moduleWidgetWordsMissed: 'Words Missed',

    // Pitch Resolution Widget
    pitchResolutionWidgetSoundsMissed: 'Sounds Missed',
    pitchResolutionWidgetGreatJob: 'No sounds missed! Great job!',
    pitchResolutionWidgetSemitones: 'Semitones',
    pitchResolutionWidgetPrompt: 'Is the second note higher or lower?',
    pitchResolutionWidgetHigher: 'Higher',
    pitchResolutionWidgetLower: 'Lower',

    // Speech Module Widget
    speechModuleWidgetFailedTranscription: 'Could not transcribe audio.',
    speechModuleWidgetPrompt: 'Repeat back what you hear!',
    speechModuleWidgetPlayAudio: 'Play',
    speechModuleWidgetStopRecording: 'Stop Recording',
    speechModuleWidgetStartRecording: 'Start Recording',
    speechModuleWidgetWhatYouSaid: 'What you said:',
    speechModuleWidgetOriginal: 'Original:',
    speechModuleWidgetAccuracy: 'Accuracy:',
    speechModuleWidgetAverage: 'Average Accuracy',
    speechModuleWidgetHighestAverage: 'Highest Average Accuracy',

    // Alternating Path Layout Widget
    alternatingPathViewChapterWords: 'View Chapter Words',

    // Animated Button Widget
    animatedButtonWidgetExercise: 'Exercise',
    animatedButtonWidgetChapterName: 'Chapter Name:',
    animatedButtonWidgetCancel: 'Cancel',
    animatedButtonWidgetStart: 'Start',

    // Module Card Widget
    moduleCardWidgetHearWords: 'HEAR WORDS',

    // Edit Custom Module
    editCustomModuleMaximumOf: 'Maximum of',
    editCustomModuleGroupsAllowed: 'groups allowed',
    editCustomModuleDeleteModule: 'Delete Module',
    editCustomModuleDeleteModuleWarning: 'This is the last answer group. Deleting it will remove the entire module. Continue?',
    editCustomModuleDeleteGroup: 'Delete Group',
    editCustomModuleDeleteGroupWarning: 'Are you sure you want to delete this answer group?',
    editCustomModuleGroupDeleted: 'Group deleted (unsaved)',
    editCustomModuleDelete: 'Delete',
    editCustomModuleGenerationFailed: 'Could not generate enough related words for group',
    editCustomModuleGenerationError: 'Error generating words for group',
    editCustomModuleSavedSuccessfully: 'Module saved successfully',
    editCustomModuleNoValidGroups: 'No valid answer groups to save. Please add at least one word.',
    editCustomModuleDiscardChanges: 'Discard Changes?',
    editCustomModuleUnsavedChangesWarning: 'You have unsaved changes.\nAre you sure you want to exit?',
    editCustomModuleKeepEditing: 'KEEP EDITING',
    editCustomModuleDiscard: 'DISCARD',
    editCustomModuleNoGroupsFound: 'No answer groups found for this module',
    editCustomModuleAddSet: 'Add Set',
    editCustomModuleSave: 'SAVE',
    editCustomModuleSet: 'Set',

    customUtilAlreadyExists: 'Modules Already Exists',
    customUtilOverwritePrompt:  'A module with this name already exists. Would you like to overwrite it?',
    customUtilReturnToModule: 'Return to Module',
    customUtilOverwrite: 'Overwrite',
    customUtilTitle: 'Module Creator',
    customUtilEntryPrompt: 'Enter your desired words!',
    customUtilFillTheRest:  'We\'ll fill in the rest of your set if\nyou enter less than four words',
    customUtilModuleName: 'Module Name',
    customUtilSaveModule: 'Save Module',

    // General (Multi-Page)
    generalAccentPreview: 'Hello this is how I sound',
    generalCancel: 'CANCEL',
    generalLoading: 'Loading...',
    generalContinue: 'CONTINUE',
    generalYouChose: 'You Chose',
    generalCorrectAnswer: 'Correct Answer',
    generalLessonComplete: 'Lesson Complete!',
    generalScore: 'Score',
    generalHighestScore: 'Highest Score',
    generalCorrect: 'Correct',
    generalIncorrect: 'Incorrect',
    generalGreat: 'Great'
  };

  static const Map<String, dynamic> VI = {
    // Home Page
    homePageTitle: 'VIHearBat',
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

    // Navigation Bar
    navBarHome: 'Home',
    navBarInsights: 'Insights',
    navBarProfile: 'Profile',

    // Sound Adjustments Page
    soundAdjustPageReady: 'Ready',
    soundAdjustPageSoundCheck: 'Sound Check!\n',
    soundAdjustPagePleaseAdjust: 'Please adjust your \nsound settings',

    // Settings Page
    settingsPageTitle: 'SETTINGS',
    settingsPageLanguageTitle: 'Language',
    settingsPageLanguageEnglish: 'English',
    settingsPageLanguageVietnamese: 'Test Language Switched (on)',

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

    // Difficulty Selection Page
    selectionPageDifficultyTitle: 'Difficulty',
    selectionPageDifficultySubtitle: 'By completing modules, you can unlock difficulty levels',
    selectionPageDifficultyNormal: 'Normal',
    selectionPageDifficultyHard: 'Hard',

    selectionPageVoiceTitle: 'Voice Type',
    selectionPageVoiceSubtitle: 'Random swaps between male and female',
    selectionPageVoiceFemale: 'Female',
    selectionPageVoiceMale: 'Male',
    selectionPageVoiceRandom: 'Random',

    selectionPageBackgroundTitle: 'Background Noise',
    selectionPageBackgroundSubtitle: 'Background noises to add an extra challenge',
    selectionPageBackgroundNone: 'None',
    selectionPageBackgroundRain: 'Rain',
    selectionPageBackgroundCoffee: 'Coffee Shop',

    selectionPageIntensityTitle: 'Noise Intensity',
    selectionPageIntensitySubtitle: 'Choose the intensity of background noises',
    selectionPageIntensityLow: 'Low',
    selectionPageIntensityMedium: 'Medium',
    selectionPageIntensityHigh: 'High',

    selectionPageStart: 'START EXERCISE',

    // Insights Page
    insightsPageTitle: 'INSIGHTS',
    insightsPageToday: 'Today',
    insightsPageTimePracticed: 'Time practiced',
    insightsPageMinuteAbbr: 'm',
    insightsPageDailyGoal: 'of daily goal achieved',
    insightsPageSpeechAccuracy: 'Speech Accuracy',
    insightsPageNoiseChallenge: 'Noise Challenge',
    insightsPageMissedWords: 'View Most Missed Words',
    insightsPageMissedSounds: 'View Most Missed Sounds',
    insightsPageSpeechOvertime: 'Speech Overtime',

    // Missed Words Page
    missedWordsPageMostMissedWords: 'Most Missed Words',

    // Missed Sounds Page
    missedSoundsPageMostMissedSounds: 'Most Missed Sounds',

    // Word Chapters Page
    wordChaptersPageTitle: 'WORD',

    // Sound Chapters Page
    soundChaptersPageTitle: 'SOUND',

    // Speech Chapters Page
    speechChaptersPageTitle: 'SPEECH',

    // Music Chapters Page
    musicChaptersPageTitle: 'MUSIC',

    // Custom Modules Page
    customModulesPageTitle: 'Custom Module Builder',
    customModulesPageCreate: 'Create Module',
    customModulesPageStart: 'START',

    // Check Button Widget
    checkButtonWidgetCheck: 'CHECK',

    // Four Answer Widget
    fourAnswerWidgetPrompt: 'What do you hear?',

    // Module Widget
    moduleWidgetWordsMissed: 'Words Missed',

    // Pitch Resolution Widget
    pitchResolutionWidgetSoundsMissed: 'Sounds Missed',
    pitchResolutionWidgetGreatJob: 'No sounds missed! Great job!',
    pitchResolutionWidgetSemitones: 'Semitones',
    pitchResolutionWidgetPrompt: 'Is the second note higher or lower?',
    pitchResolutionWidgetHigher: 'Higher',
    pitchResolutionWidgetLower: 'Lower',

    // Speech Module Widget
    speechModuleWidgetFailedTranscription: 'Could not transcribe audio.',
    speechModuleWidgetPrompt: 'Repeat back what you hear!',
    speechModuleWidgetPlayAudio: 'Play',
    speechModuleWidgetStopRecording: 'Stop Recording',
    speechModuleWidgetStartRecording: 'Start Recording',
    speechModuleWidgetWhatYouSaid: 'What you said:',
    speechModuleWidgetOriginal: 'Original:',
    speechModuleWidgetAccuracy: 'Accuracy:',
    speechModuleWidgetAverage: 'Average Accuracy',
    speechModuleWidgetHighestAverage: 'Highest Average Accuracy',

    // Alternating Path Layout Widget
    alternatingPathViewChapterWords: 'View Chapter Words',

    // Animated Button Widget
    animatedButtonWidgetExercise: 'Exercise',
    animatedButtonWidgetChapterName: 'Chapter Name:',
    animatedButtonWidgetCancel: 'Cancel',
    animatedButtonWidgetStart: 'Start',

    // Module Card Widget
    moduleCardWidgetHearWords: 'HEAR WORDS',

    // Edit Custom Module
    editCustomModuleMaximumOf: 'Maximum of',
    editCustomModuleGroupsAllowed: 'groups allowed',
    editCustomModuleDeleteModule: 'Delete Module',
    editCustomModuleDeleteModuleWarning: 'This is the last answer group. Deleting it will remove the entire module. Continue?',
    editCustomModuleDeleteGroup: 'Delete Group',
    editCustomModuleDeleteGroupWarning: 'Are you sure you want to delete this answer group?',
    editCustomModuleGroupDeleted: 'Group deleted (unsaved)',
    editCustomModuleDelete: 'Delete',
    editCustomModuleGenerationFailed: 'Could not generate enough related words for group',
    editCustomModuleGenerationError: 'Error generating words for group',
    editCustomModuleSavedSuccessfully: 'Module saved successfully',
    editCustomModuleNoValidGroups: 'No valid answer groups to save. Please add at least one word.',
    editCustomModuleDiscardChanges: 'Discard Changes?',
    editCustomModuleUnsavedChangesWarning: 'You have unsaved changes.\nAre you sure you want to exit?',
    editCustomModuleKeepEditing: 'KEEP EDITING',
    editCustomModuleDiscard: 'DISCARD',
    editCustomModuleNoGroupsFound: 'No answer groups found for this module',
    editCustomModuleAddSet: 'Add Set',
    editCustomModuleSave: 'SAVE',
    editCustomModuleSet: 'Set',

    // General (Multi-Page)
    generalAccentPreview: 'Hello this is how I sound',
    generalCancel: 'CANCEL',
    generalLoading: 'Loading...',
    generalContinue: 'CONTINUE',
    generalYouChose: 'You Chose',
    generalCorrectAnswer: 'Correct Answer',
    generalLessonComplete: 'Lesson Complete!',
    generalScore: 'Score',
    generalHighestScore: 'Highest Score',
    generalCorrect: 'Correct',
    generalIncorrect: 'Incorrect',
    generalGreat: 'Great'
  };

  // idk some examples of other langs from the package readme
  static const Map<String, dynamic> KM = {homePageWordsTitle: 'ការធ្វើមូលដ្ឋានីយកម្ម'};
  static const Map<String, dynamic> JA = {homePageWordsTitle: 'ローカリゼーション'};
}
