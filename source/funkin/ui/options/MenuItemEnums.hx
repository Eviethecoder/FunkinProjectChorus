package funkin.ui.options;

// Add enums for use with `EnumPreferenceItem` here!

@:enum
abstract NoteHitSoundType(String) from String to String
{
  var None;
  var Psych;
  var Beep1;
  var Beep2;
  // var Honk;
}

@:enum
abstract Hudstyle(String) from String to String
{
  var Funkin;
  var Test1;
  var Test2;
  var Test3;
}

@:enum
abstract Rankingtype(String) from String to String
{
  var Hard;
  var Intended;
  var Pussy;
}

@:enum
abstract TimebarType(String) from String to String
{
  var None;
  var Classic;
  var Gradient;
  // var Honk;
}

class MyOptionEnum
{
  public static inline var YuhUh = "true"; // "true" is the value's ID
  public static inline var NuhUh = "false";
}
