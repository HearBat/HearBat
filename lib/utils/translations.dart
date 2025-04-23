// ignore_for_file: constant_identifier_names

// need this for AppLocale.title.getString(context) and I dont want to import 2 files everywhere we need to translate
export 'package:flutter_localization/flutter_localization.dart';




// for the formatting it would be nice if we could have some standard format maybe
// {page}{some identifier} or {widget}{some identifier}
// just so we kind of know what it is off a first look, and let's try to keep translations together based on where theyre being used

// but also let's not worry TOO much since we are gonna uproot this for UI changes later

mixin AppLocale {
  static const String homePageTrainWords = 'homePageTrainWords';
  static const String homePageTrainSounds = 'homePageTrainSounds';

  static const Map<String, dynamic> EN = {
    homePageTrainWords: 'Train Words',
    homePageTrainSounds: 'Train Sounds' 
  };


  // idk some examples of other langs from the package readme
  static const Map<String, dynamic> KM = {homePageTrainWords: 'ការធ្វើមូលដ្ឋានីយកម្ម'};
  static const Map<String, dynamic> JA = {homePageTrainWords: 'ローカリゼーション'};
}
