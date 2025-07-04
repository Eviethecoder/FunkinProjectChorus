package funkin;

import funkin.save.Save;

/**
 * A core class which provides a store of user-configurable, globally relevant values.
 */
class Preferences
{
  /**
   * Whether some particularly fowl language is displayed.
   * @default `true`
   */
  public static var naughtyness(get, set):Bool;

  static function get_naughtyness():Bool
  {
    return Save?.instance?.options?.naughtyness;
  }

  static function set_naughtyness(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.naughtyness = value;
    save.flush();
    return value;
  }

  public static var framerate(get, set):Int;

  static function get_framerate():Int
  {
    #if web
    return 60;
    #else
    return Save?.instance?.options?.framerate ?? 60;
    #end
  }

  static function set_framerate(value:Int):Int
  {
    #if web
    return 60;
    #else
    var save:Save = Save.instance;
    save.options.framerate = value;
    save.flush();
    FlxG.updateFramerate = value;
    FlxG.drawFramerate = value;
    return value;
    #end
  }

  /**
   * if you want notehit sounds during gameplay .
   * @default `false`
   */
  public static var noteHitSound(get, set):String;

  static function get_noteHitSound():String
  {
    return Save?.instance?.options?.noteHitSound;
  }

  static function set_noteHitSound(value:String):String
  {
    var save:Save = Save.instance;
    save.options.noteHitSound = value;
    save.flush();
    return value;
  }

  /**
   * if you want notehit sounds during gameplay .
   * @default `Intended`
   */
  public static var rankingtype(get, set):String;

  static function get_rankingtype():String
  {
    return Save?.instance?.options?.rankingtype;
  }

  static function set_rankingtype(value:String):String
  {
    var save:Save = Save.instance;
    save.options.rankingtype = value;
    save.flush();
    return value;
  }

  /**
   * if you want notehit sounds during gameplay .
   * @default `false`
   */
  public static var noteHitSoundopp(get, set):String;

  static function get_noteHitSoundopp():String
  {
    return Save?.instance?.options?.noteHitSoundopp;
  }

  static function set_noteHitSoundopp(value:String):String
  {
    var save:Save = Save.instance;
    save.options.noteHitSoundopp = value;
    save.flush();
    return value;
  }

  /**
   * The timebar type. defaults to classic
   * @default `classic`
   */
  public static var timebar(get, set):String;

  static function get_timebar():String
  {
    return Save?.instance?.options?.timebar;
  }

  static function set_timebar(value:String):String
  {
    var save:Save = Save.instance;
    save.options.timebar = value;
    save.flush();
    return value;
  }

  /**
   * notehitsound volume .
   * @default `50`
   */
  public static var noteHitSoundVolume(get, set):Int;

  static function get_noteHitSoundVolume():Int
  {
    return Save?.instance?.options?.noteHitSoundVolume;
  }

  static function set_noteHitSoundVolume(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.noteHitSoundVolume = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline is centered
   * @default `false`
   */
  public static var middlescroll(get, set):Bool;

  static function get_middlescroll():Bool
  {
    return Save?.instance?.options?.middlescroll;
  }

  static function set_middlescroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.middlescroll = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline is at the bottom of the screen rather than the top.
   * @default `false`
   */
  public static var downscroll(get, set):Bool;

  static function get_downscroll():Bool
  {
    return Save?.instance?.options?.downscroll;
  }

  static function set_downscroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.downscroll = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, notehits when no note is present wont penalize ypu.
   * @default `true`
   */
  public static var ghostapping(get, set):Bool;

  static function get_ghostapping():Bool
  {
    return Save?.instance?.options?.ghostapping;
  }

  static function set_ghostapping(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.ghostapping = value;
    save.flush();
    return value;
  }

  /**
   * If disabled, flashing lights in the main menu and other areas will be less intense.
   * @default `true`
   */
  public static var flashingLights(get, set):Bool;

  static function get_flashingLights():Bool
  {
    return Save?.instance?.options?.flashingLights ?? true;
  }

  static function set_flashingLights(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.flashingLights = value;
    save.flush();
    return value;
  }

  /**
   * If disabled, the camera bump synchronized to the beat.
   * @default `false`
   */
  public static var zoomCamera(get, set):Bool;

  static function get_zoomCamera():Bool
  {
    return Save?.instance?.options?.zoomCamera;
  }

  static function set_zoomCamera(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.zoomCamera = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, an FPS and memory counter will be displayed even if this is not a debug build.
   * @default `false`
   */
  public static var debugDisplay(get, set):Bool;

  static function get_debugDisplay():Bool
  {
    return Save?.instance?.options?.debugDisplay;
  }

  static function set_debugDisplay(value:Bool):Bool
  {
    if (value != Save.instance.options.debugDisplay)
    {
      toggleDebugDisplay(value);
    }

    var save = Save.instance;
    save.options.debugDisplay = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the game will automatically pause when tabbing out.
   * @default `true`
   */
  public static var autoPause(get, set):Bool;

  static function get_autoPause():Bool
  {
    return Save?.instance?.options?.autoPause ?? true;
  }

  static function set_autoPause(value:Bool):Bool
  {
    if (value != Save.instance.options.autoPause) FlxG.autoPause = value;

    var save:Save = Save.instance;
    save.options.autoPause = value;
    save.flush();
    return value;
  }

  /**
   * Loads the user's preferences from the save data and apply them.
   */
  public static function init():Void
  {
    // Apply the autoPause setting (enables automatic pausing on focus lost).
    FlxG.autoPause = Preferences.autoPause;
    // Apply the debugDisplay setting (enables the FPS and RAM display).
    toggleDebugDisplay(Preferences.debugDisplay);
  }

  static function toggleDebugDisplay(show:Bool):Void
  {
    if (show)
    {
      // Enable the debug display.
      FlxG.stage.addChild(Main.fpsCounter);
      #if !html5
      FlxG.stage.addChild(Main.memoryCounter);
      #end
    }
    else
    {
      // Disable the debug display.
      FlxG.stage.removeChild(Main.fpsCounter);
      #if !html5
      FlxG.stage.removeChild(Main.memoryCounter);
      #end
    }
  }
}
