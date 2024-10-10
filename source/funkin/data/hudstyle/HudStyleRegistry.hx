package funkin.data.hudstyle;

import funkin.play.hudstyle.HudStyle;
import funkin.play.hudstyle.ScriptedHudStyle;
import funkin.data.hudstyle.HudStyleData;

class HudStyleRegistry extends BaseRegistry<HudStyle, HudStyleData>
{
  /**
   * The current version string for the note style data format.
   * Handle breaking changes by incrementing this value
   * and adding migration to the `migrateHudStyleData()` function.
   */
  public static final HUD_STYLE_DATA_VERSION:thx.semver.Version = "1.1.0";

  public static final HUD_STYLE_DATA_VERSION_RULE:thx.semver.VersionRule = "1.1.x";

  public static var instance(get, never):HudStyleRegistry;
  static var _instance:Null<HudStyleRegistry> = null;

  static function get_instance():HudStyleRegistry
  {
    if (_instance == null) _instance = new HudStyleRegistry();
    return _instance;
  }

  public function new()
  {
    super('HUDSTYLE', 'hudstyles', HUD_STYLE_DATA_VERSION_RULE);
  }

  public function fetchDefault():HudStyle
  {
    return fetchEntry(Constants.DEFAULT_HUD_STYLE);
  }

  /**
   * Read, parse, and validate the JSON data and produce the corresponding data object.
   */
  public function parseEntryData(id:String):Null<HudStyleData>
  {
    // JsonParser does not take type parameters,
    // otherwise this function would be in BaseRegistry.
    var parser = new json2object.JsonParser<HudStyleData>();
    parser.ignoreUnknownVariables = false;

    switch (loadEntryFile(id))
    {
      case {fileName: fileName, contents: contents}:
        parser.fromJson(contents, fileName);
      default:
        return null;
    }

    if (parser.errors.length > 0)
    {
      printErrors(parser.errors, id);
      return null;
    }
    return parser.value;
  }

  /**
   * Parse and validate the JSON data and produce the corresponding data object.
   *
   * NOTE: Must be implemented on the implementation class.
   * @param contents The JSON as a string.
   * @param fileName An optional file name for error reporting.
   */
  public function parseEntryDataRaw(contents:String, ?fileName:String):Null<HudStyleData>
  {
    var parser = new json2object.JsonParser<HudStyleData>();
    parser.ignoreUnknownVariables = false;
    parser.fromJson(contents, fileName);

    if (parser.errors.length > 0)
    {
      printErrors(parser.errors, fileName);
      return null;
    }
    return parser.value;
  }

  function createScriptedEntry(clsName:String):HudStyle
  {
    return ScriptedHudStyle.init(clsName, "unknown");
  }

  function getScriptedClassNames():Array<String>
  {
    return ScriptedHudStyle.listScriptClasses();
  }
}
