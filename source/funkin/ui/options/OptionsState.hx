package funkin.ui.options;

import funkin.ui.debug.latency.LatencyState;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal;
import funkin.audio.FunkinSound;
import funkin.ui.mainmenu.MainMenuState;
import funkin.ui.MusicBeatState;
import funkin.graphics.shaders.HSVShader;
import funkin.util.WindowUtil;
import funkin.audio.FunkinSound;
import funkin.play.PlayState;
import funkin.input.Controls;
import funkin.play.song.Song;
import funkin.ui.transition.LoadingState;

class OptionsState extends MusicBeatState
{
  var pages = new Map<PageName, Page>();
  var currentName:PageName = Options;
  var currentPage(get, never):Page;

  public static var togame:Bool = false;
  public static var currentSong:Song;

  public static var currentDifficulty:String;
  public static var currentVariation:String;

  inline function get_currentPage():Page
    return pages[currentName];

  override function create():Void
  {
    var menuBG = new FlxSprite().loadGraphic(Paths.image('menuBG'));
    var hsv = new HSVShader();
    hsv.hue = -0.6;
    hsv.saturation = 0.9;
    hsv.value = 3.6;
    menuBG.shader = hsv;
    FlxG.debugger.track(hsv);
    menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
    menuBG.updateHitbox();
    menuBG.screenCenter();
    menuBG.scrollFactor.set(0, 0);
    add(menuBG);

    var options = addPage(Options, new OptionsMenu());
    var colors = addPage(Colors, new ColorsMenu());
    var preferences = addPage(Preferences, new PreferencesMenu());
    var controls = addPage(Controls, new ControlsMenu());

    if (options.hasMultipleOptions())
    {
      options.onExit.add(exit);
      colors.onExit.add(exitColors);
      controls.onExit.add(exitControls);
      preferences.onExit.add(switchPage.bind(Options));
    }
    else
    {
      // No need to show Options page
      controls.onExit.add(exit);
      setPage(Controls);
    }

    // disable for intro transition
    currentPage.enabled = false;
    super.create();
  }

  function addPage<T:Page>(name:PageName, page:T)
  {
    page.onSwitch.add(switchPage);
    pages[name] = page;
    add(page);
    page.exists = currentName == name;
    return page;
  }

  function setPage(name:PageName)
  {
    if (pages.exists(currentName))
    {
      currentPage.exists = false;
      currentPage.visible = false;
    }

    currentName = name;

    if (pages.exists(currentName))
    {
      currentPage.exists = true;
      currentPage.visible = true;
    }
  }

  override function finishTransIn()
  {
    super.finishTransIn();

    currentPage.enabled = true;
  }

  function switchPage(name:PageName)
  {
    // TODO: Animate this transition?
    setPage(name);
  }

  function exitControls():Void
  {
    // Apply any changes to the controls.
    PlayerSettings.reset();
    PlayerSettings.init();

    switchPage(Options);
  }

  function exitColors():Void
  {
    switchPage(Options);
  }

  function exit()
  {
    if (togame == false)
    {
      currentPage.enabled = false;
      // TODO: Animate this transition?
      FlxG.switchState(() -> new MainMenuState());
    }
    else
    {
      currentPage.enabled = false;
      // TODO: Animate this transition?
      trace(currentSong);
      LoadingState.loadPlayState(
        {
          targetSong: currentSong,
          targetDifficulty: currentDifficulty,
          targetVariation: currentVariation,
          practiceMode: false,
          minimalMode: false,

          #if (debug || FORCE_DEBUG_VERSION)
          botPlayMode: FlxG.keys.pressed.SHIFT,
          #else
          botPlayMode: false,
          #end
        }, true);
    }
  }
}

class Page extends FlxGroup
{
  public var onSwitch(default, null) = new FlxTypedSignal<PageName->Void>();
  public var onExit(default, null) = new FlxSignal();

  public var enabled(default, set) = true;
  public var canExit = true;

  var controls(get, never):Controls;

  inline function get_controls()
    return PlayerSettings.player1.controls;

  var subState:FlxSubState;

  inline function switchPage(name:PageName)
  {
    onSwitch.dispatch(name);
  }

  inline function exit()
  {
    onExit.dispatch();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (enabled) updateEnabled(elapsed);
  }

  function updateEnabled(elapsed:Float)
  {
    if (canExit && controls.BACK)
    {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      exit();
    }
  }

  function set_enabled(value:Bool)
  {
    return this.enabled = value;
  }

  function openPrompt(prompt:Prompt, onClose:Void->Void)
  {
    enabled = false;
    prompt.closeCallback = function() {
      enabled = true;
      if (onClose != null) onClose();
    }

    FlxG.state.openSubState(prompt);
  }

  override function destroy()
  {
    super.destroy();
    onSwitch.removeAll();
  }
}

class OptionsMenu extends Page
{
  var items:TextMenuList;

  public function new()
  {
    super();

    add(items = new TextMenuList());
    createItem("PREFERENCES", function() switchPage(Preferences));
    createItem("CONTROLS", function() switchPage(Controls));
    createItem("COLLORS", function() switchPage(Colors));
    createItem("INPUT OFFSETS", function() {
      FlxG.state.openSubState(new LatencyState());
    });

    #if newgrounds
    if (NGio.isLoggedIn) createItem("LOGOUT", selectLogout);
    else
      createItem("LOGIN", selectLogin);
    #end
    createItem("EXIT", exit);
    updateDiscordRPC();
  }

  function createItem(name:String, callback:Void->Void, fireInstantly = false)
  {
    var item = items.createItem(0, 100 + items.length * 100, name, BOLD, callback);
    item.fireInstantly = fireInstantly;
    item.screenCenter(X);
    return item;
  }

  override function set_enabled(value:Bool)
  {
    items.enabled = value;
    return super.set_enabled(value);
  }

  function updateDiscordRPC():Void
  {
    funkin.api.discord.DiscordClient.instance.setPresence(
      {
        state: null,
        details: 'Changing Options'
      });
  }

  /**
   * True if this page has multiple options, excluding the exit option.
   * If false, there's no reason to ever show this page.
   */
  public function hasMultipleOptions():Bool
  {
    return items.length > 2;
  }

  #if newgrounds
  function selectLogin()
  {
    openNgPrompt(NgPrompt.showLogin());
  }

  function selectLogout()
  {
    openNgPrompt(NgPrompt.showLogout());
  }

  /**
   * Calls openPrompt and redraws the login/logout button
   * @param prompt
   * @param onClose
   */
  public function openNgPrompt(prompt:Prompt, ?onClose:Void->Void)
  {
    var onPromptClose = checkLoginStatus;
    if (onClose != null)
    {
      onPromptClose = function() {
        checkLoginStatus();
        onClose();
      }
    }

    openPrompt(prompt, onPromptClose);
  }

  function checkLoginStatus()
  {
    // this shit don't work!! wtf!!!!
    var prevLoggedIn = items.has("logout");
    if (prevLoggedIn && !NGio.isLoggedIn) items.resetItem("logout", "login", selectLogin);
    else if (!prevLoggedIn && NGio.isLoggedIn) items.resetItem("login", "logout", selectLogout);
  }
  #end
}

enum PageName
{
  Options;
  Controls;
  Colors;
  Mods;
  Preferences;
}
