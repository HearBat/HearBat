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
  static const String soundAdjustPageSoundCheck = 'soundAdjustPageSoundCheck';
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
  static const String settingsPageVoiceVIFemale = 'settingsPageVoiceVIFemale';
  static const String settingsPageVoiceVIMale = 'settingsPageVoiceVIMale';


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
  static const String insightsPageSpeechAccuracyGraphTitle = 'insightsPageSpeechAccuracyGraphTitle';

  // Missed Answers Page
  static const String missedAnswersPageMissed = 'missedAnswersPageMissed';

  // Missed Words Page
  static const String missedWordsPageMostMissedWords = 'missedWordsPageMostMissedWords';
  static const String missedWordsPageEmpty = 'missedWordsPageEmpty';

  // Missed Sounds Page
  static const String missedSoundsPageMostMissedSounds = 'missedSoundsPageMostMissedSounds';
  static const String missedSoundsPageEmpty = 'missedSoundsPageEmpty';

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

  // Daily Streak Page
  static const String dailyStreakPageTitle = 'dailyStreakPageTitle';
  static const String dailyStreakPageLongestStreak = 'dailyStreakPageLongestStreak';
  static const String dailyStreakPageKeepGoing = 'dailyStreakPageKeepGoing';
  static const String dailyStreakPageStartPracticing = 'dailyStreakPageStartPracticing';
  static const String dailyStreakPageThisWeek = 'dailyStreakPageThisWeek';
  static const String dailyStreakPagePracticeOn = 'dailyStreakPagePracticeOn';
  static const String dailyStreakPageErrorLoading = 'dailyStreakPageErrorLoading';
  static const String dailyStreakPageDays = 'dailyStreakPageDays';
  static const String dailyStreakPageHours = 'dailyStreakPageHours';
  static const String dailyStreakPageMinutes = 'dailyStreakPageMinutes';
  static const String dailyStreakPageLessThanMinute = 'dailyStreakPageLessThanMinute';
  static const String dailyStreakPageWeekdayMonday = 'dailyStreakPageWeekdayMonday';
  static const String dailyStreakPageWeekdayTuesday = 'dailyStreakPageWeekdayTuesday';
  static const String dailyStreakPageWeekdayWednesday = 'dailyStreakPageWeekdayWednesday';
  static const String dailyStreakPageWeekdayThursday = 'dailyStreakPageWeekdayThursday';
  static const String dailyStreakPageWeekdayFriday = 'dailyStreakPageWeekdayFriday';
  static const String dailyStreakPageWeekdaySaturday = 'dailyStreakPageWeekdaySaturday';
  static const String dailyStreakPageWeekdaySunday = 'dailyStreakPageWeekdaySunday';


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
  static const String generalPleaseSelect = 'generalPleaseSelect';
  static const String generalAsTheAnswer = 'generalAsTheAnswer';

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
    settingsPageLanguageVietnamese: 'Vietnamese',

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
    settingsPageVoiceVIFemale: 'Vietnamese Female',
    settingsPageVoiceVIMale: 'Vietnamese Male',

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
    insightsPageSpeechAccuracyGraphTitle: 'Speech Accuracy',

    // Missed Answers Page
    missedAnswersPageMissed: 'Missed',

    // Missed Words Page
    missedWordsPageMostMissedWords: 'Most Missed Words',
    missedWordsPageEmpty: 'No missed words yet.',

    // Missed Sounds Page
    missedSoundsPageMostMissedSounds: 'Most Missed Sounds',
    missedSoundsPageEmpty: 'No missed sounds yet.',

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

    // Daily Streak Page
    dailyStreakPageTitle: 'Your Streak',
    dailyStreakPageLongestStreak: 'Longest streak: {days} days',
    dailyStreakPageKeepGoing: 'Keep it going!',
    dailyStreakPageStartPracticing: 'Start practicing!',
    dailyStreakPageThisWeek: 'This week',
    dailyStreakPagePracticeOn: 'Practice on {date}: {time}',
    dailyStreakPageErrorLoading: 'Error loading practice time',
    dailyStreakPageDays: '{days} days',
    dailyStreakPageHours: '{hours}h {minutes}m',
    dailyStreakPageMinutes: '{minutes}m',
    dailyStreakPageLessThanMinute: '<1m',
    dailyStreakPageWeekdayMonday: 'M',
    dailyStreakPageWeekdayTuesday: 'T',
    dailyStreakPageWeekdayWednesday: 'W',
    dailyStreakPageWeekdayThursday: 'T',
    dailyStreakPageWeekdayFriday: 'F',
    dailyStreakPageWeekdaySaturday: 'S',
    dailyStreakPageWeekdaySunday: 'S',

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
    generalGreat: 'Great',
    generalPleaseSelect: 'Please select',
    generalAsTheAnswer: 'as the answer'
  };

  static const Map<String, dynamic> VI = {
    homePageTitle: 'HearBat',
    homePageSubtitle: 'bạn đồng hành thính giác của bạn',
    homePageWordsTitle: 'Tập nghe từ',
    homePageSoundsTitle: 'Tập nghe âm thanh',
    homePageSpeechTitle: 'Tập nói theo',
    homePageMusicTitle: 'Tập nghe âm nhạc',
    homePageCustomTitle: 'Tự tạo mô-đun ',
    homePageWordsDesc: 'Làm sắc nét khả năng nghe của bạn với bộ sưu tập từ vựng đa dạng',
    homePageSoundsDesc: 'Khám phá nhiều loại âm thanh, từ tiếng ồn thành phố đến tiếng của thiên nhiên',
    homePageSpeechDesc: 'Cải thiện khả năng nghe của bạn bằng cách nghe các câu và lặp lại chúng',
    homePageMusicDesc: 'Rèn luyện tai của bạn theo các mẫu nhạc và các biến thể cao độ',
    homePageCustomDesc: 'Cá nhân hóa việc học thính giác của bạn bằng cách tạo các mô-đun của riêng bạn',
    navBarHome: 'Trang chủ',
    navBarInsights: 'Thông tin chi tiết',
    navBarProfile: 'Hồ sơ',
    soundAdjustPageReady: 'Sẵn sàng',
    soundAdjustPageSoundCheck: 'Kiểm tra âm thanh!\n',
    soundAdjustPagePleaseAdjust: 'Điều chỉnh âm lượng cho đến khi bạn có thể thoải mái nghe nhạc',
    settingsPageTitle: 'CÀI ĐẶT',
    settingsPageLanguageTitle: 'Ngôn ngữ',
    settingsPageLanguageEnglish: 'Tiếng Anh',
    settingsPageLanguageVietnamese: 'Tiếng Việt',
    settingsPageFeedbackTitle: 'Tiếng phản hồi',
    settingsPageFeedbackOn: 'Bật',
    settingsPageFeedbackOff: 'Tắt',
    settingsPageVoiceTitle: 'Chọn giọng nói',
    settingsPageVoiceUSFemale: 'Nữ Mỹ',
    settingsPageVoiceUSMale: 'Nam Mỹ',
    settingsPageVoiceUKFemale: 'Tiếng Anh Nữ',
    settingsPageVoiceUKMale: 'Tiếng Anh Nam',
    settingsPageVoiceINFemale: 'Nữ Ấn Độ',
    settingsPageVoiceINMale: 'Nam Ấn Độ',
    settingsPageVoiceAUFemale: 'Nữ Úc',
    settingsPageVoiceAUMale: 'Nam Úc',
    settingsPageVoiceVIFemale: 'Nữ Việt Nam',
    settingsPageVoiceVIMale: 'Nam Việt Nam',
    settingsPageClearCache: 'XÓA BỘ NHỚ',
    selectionPageDifficultyTitle: 'Trình độ khó',
    selectionPageDifficultySubtitle: 'Bằng cách hoàn thành các mô-đun, bạn có thể mở khóa các cấp độ khó',
    selectionPageDifficultyNormal: 'Bình thường',
    selectionPageDifficultyHard: 'Khó',
    selectionPageVoiceTitle: 'Giọng nói',
    selectionPageVoiceSubtitle: 'Sự hoán đổi ngẫu nhiên giữa nam và nữ',
    selectionPageVoiceFemale: 'Nữ giới',
    selectionPageVoiceMale: 'Nam giới',
    selectionPageVoiceRandom: 'Ngẫu nhiên',
    selectionPageBackgroundTitle: 'Tiếng ồn bối cảnh',
    selectionPageBackgroundSubtitle: 'Tiếng bối cảnh để tăng thêm thử thách',
    selectionPageBackgroundNone: 'Không tiếng',
    selectionPageBackgroundRain: 'Cơn mưa',
    selectionPageBackgroundCoffee: 'Quán cà phê',
    selectionPageIntensityTitle: 'Chế độ ồn',
    selectionPageIntensitySubtitle: 'Chọn chế độ tiếng bối cảnh',
    selectionPageIntensityLow: 'Thấp',
    selectionPageIntensityMedium: 'Trung bình',
    selectionPageIntensityHigh: 'Cao',
    selectionPageStart: 'BẮT ĐẦU',
    insightsPageTitle: 'THÔNG TIN CHI TIẾT',
    insightsPageToday: 'Hôm nay',
    insightsPageTimePracticed: 'Thời gian luyện tập',
    insightsPageMinuteAbbr: 'ph',
    insightsPageDailyGoal: 'của mục tiêu hàng ngày đạt được',
    insightsPageSpeechAccuracy: 'chính xác khi nói',
    insightsPageNoiseChallenge: 'Thử thách tiếng',
    insightsPageMissedWords: 'Xem những từ bị sai nhiều nhất',
    insightsPageMissedSounds: 'Xem những âm thanh bị sai nhiều nhất',
    insightsPageSpeechOvertime: 'Trình độ nói theo theo thời gian',
    insightsPageSpeechAccuracyGraphTitle: 'Độ Chính Xác Khi Nói',
    missedAnswersPageMissed: 'Sai',
    missedWordsPageMostMissedWords: 'Những từ bị sai nhiều nhất',
    missedWordsPageEmpty: 'Chưa có từ nào bị sai.',
    missedSoundsPageMostMissedSounds: 'Âm thanh bị sai nhiều nhất',
    missedSoundsPageEmpty: 'Chưa có âm thanh nào bị sai.',
    wordChaptersPageTitle: 'TỪ',
    soundChaptersPageTitle: 'ÂM THANH',
    speechChaptersPageTitle: 'NÓI THEO',
    musicChaptersPageTitle: 'ÂM NHẠC',
    customModulesPageTitle: 'Tự tạo mô-đun',
    customModulesPageCreate: 'Tạo mô-đun',
    customModulesPageStart: 'BẮT ĐẦU',
    checkButtonWidgetCheck: 'KIỂM TRA',
    fourAnswerWidgetPrompt: 'Bạn nghe thấy gì?',
    moduleWidgetWordsMissed: 'Từ bị sai',
    pitchResolutionWidgetSoundsMissed: 'Âm thanh bị sai',
    pitchResolutionWidgetGreatJob: 'Không có nốt nhạc nào bị sai! Làm tốt lắm!',
    pitchResolutionWidgetSemitones: 'Nửa cung',
    pitchResolutionWidgetPrompt: 'Nốt thứ hai cao hơn hay thấp hơn?',
    pitchResolutionWidgetHigher: 'Cao hơn',
    pitchResolutionWidgetLower: 'Thấp hơn',
    speechModuleWidgetFailedTranscription: 'Không thể dịch âm thanh.',
    speechModuleWidgetPrompt: 'Lặp lại những gì bạn nghe được!',
    speechModuleWidgetPlayAudio: 'Chơi',
    speechModuleWidgetStopRecording: 'Dừng ghi âm',
    speechModuleWidgetStartRecording: 'Bắt đầu ghi âm',
    speechModuleWidgetWhatYouSaid: 'Bạn đã nói:',
    speechModuleWidgetOriginal: 'Câu gốc:',
    speechModuleWidgetAccuracy: 'Phần trăm chính xác:',
    speechModuleWidgetAverage: 'Phần trăm chính xác trung bình',
    speechModuleWidgetHighestAverage: 'Phần trăm chính xác trung bình cao nhất',
    alternatingPathViewChapterWords: 'Xem chương từ',
    animatedButtonWidgetExercise: 'Bài tập',
    animatedButtonWidgetChapterName: 'Tên chương:',
    animatedButtonWidgetCancel: 'Hủy bỏ',
    animatedButtonWidgetStart: 'Bắt đầu',
    moduleCardWidgetHearWords: 'NGHE TỪ',
    editCustomModuleMaximumOf: 'Tối đa của',
    editCustomModuleGroupsAllowed: 'nhóm được phép',
    editCustomModuleDeleteModule: 'Xóa Mô-đun',
    editCustomModuleDeleteModuleWarning: 'Đây là nhóm câu trả lời cuối cùng. Xóa nhóm này sẽ xóa toàn bộ mô-đun. Tiếp tục?',
    editCustomModuleDeleteGroup: 'Xóa nhóm',
    editCustomModuleDeleteGroupWarning: 'Bạn có chắc chắn muốn xóa nhóm câu trả lời này không?',
    editCustomModuleGroupDeleted: 'Nhóm đã xóa (chưa lưu)',
    editCustomModuleDelete: 'Xóa bỏ',
    editCustomModuleGenerationFailed: 'Không thể tạo đủ từ liên quan cho nhóm',
    editCustomModuleGenerationError: 'Lỗi khi tạo từ cho nhóm',
    editCustomModuleSavedSuccessfully: 'Mô-đun đã được lưu thành công',
    editCustomModuleNoValidGroups: 'Không có nhóm câu trả lời hợp lệ nào để lưu. Vui lòng thêm ít nhất một từ.',
    editCustomModuleDiscardChanges: 'Hủy bỏ thay đổi?',
    editCustomModuleUnsavedChangesWarning: 'Bạn chưa lưu thay đổi.\nBạn có chắc chắn muốn thoát không?',
    editCustomModuleKeepEditing: 'TIẾP TỤC CHỈNH SỬA',
    editCustomModuleDiscard: 'BỎ QUA',
    editCustomModuleNoGroupsFound: 'Không tìm thấy nhóm câu trả lời nào cho mô-đun này',
    editCustomModuleAddSet: 'Thêm Bộ',
    editCustomModuleSave: 'LƯU',
    editCustomModuleSet: 'Bộ',
    customUtilAlreadyExists: 'Mô-đun đã có',
    customUtilReturnToModule: 'Quay lại mô-đun',
    customUtilOverwrite: 'Ghi qua',
    customUtilTitle: 'Tạo mô-đun',
    customUtilEntryPrompt: 'Nhập từ bạn muốn!',
    customUtilFillTheRest: 'Chúng tôi sẽ điền phần còn lại của bộ của bạn nếu bạn nhập ít hơn bốn từ',
    customUtilModuleName: 'Tên mô-đun',
    customUtilSaveModule: 'Lưu mô-đun',
    generalAccentPreview: 'Xin chào, đây là cách tôi nói',
    generalCancel: 'HỦY BỎ',
    generalLoading: 'Đang tải...',
    generalContinue: 'TIẾP TỤC',
    generalYouChose: 'Bạn đã chọn',
    generalCorrectAnswer: 'Câu trả lời đúng',
    generalLessonComplete: 'Bài học đã hoàn tất!',
    generalScore: 'Điểm',
    generalHighestScore: 'Điểm cao nhất',
    generalCorrect: 'Chính xác',
    generalIncorrect: 'Không đúng',
    generalGreat: 'Tuyệt',
    generalPleaseSelect: 'Vui lòng chọn',
    generalAsTheAnswer: 'làm câu trả lời',
    dailyStreakPageTitle: 'Chuỗi ngày của bạn',
    dailyStreakPageLongestStreak: 'Chuỗi dài nhất: {days} ngày',
    dailyStreakPageKeepGoing: 'Tiếp tục phát huy nhé!',
    dailyStreakPageStartPracticing: 'Bắt đầu luyện tập thôi!',
    dailyStreakPageThisWeek: 'Tuần này',
    dailyStreakPagePracticeOn: 'Luyện tập vào {date}: {time}',
    dailyStreakPageErrorLoading: 'Lỗi khi tải thời gian luyện tập',
    dailyStreakPageDays: '{days} ngày',
    dailyStreakPageHours: '{hours}giờ {minutes}phút',
    dailyStreakPageMinutes: '{minutes}phút',
    dailyStreakPageLessThanMinute: '<1phút',
    dailyStreakPageWeekdayMonday: 'T2',
    dailyStreakPageWeekdayTuesday: 'T3',
    dailyStreakPageWeekdayWednesday: 'T4',
    dailyStreakPageWeekdayThursday: 'T5',
    dailyStreakPageWeekdayFriday: 'T6',
    dailyStreakPageWeekdaySaturday: 'T7',
    dailyStreakPageWeekdaySunday: 'CN',
  };

  static String fetchContextFreeTranslation(String language, String key) {
    String value = '$language[$key]';
    switch (language) {
      case 'English':
        value = EN[key];
      case 'Vietnamese':
        value = VI[key];
    }
    return value;
  }
}
