package funkin.play.event;

// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;
import funkin.play.character.CharacterData.CharacterDataParser;
import flixel.graphics.frames.FlxFramesCollection;

/**
 * This class represents a handler for a type of song event.
 * It is used by the ScriptedSongEvent class to handle user-defined events.
 */
class CharacterwapSongEvent extends SongEvent
{
  public function new()
  {
    super('Characterswap');
  }

  /**
   * Handles a song event that matches this handler's ID.
   * @param data The data associated with the event.
   */
  public override function handleEvent(data:SongEventData):Void
  {
    var targetName = data.getString('target');
    var newcharacter = data.getString('character');

    var precache = CharacterDataParser.fetchCharacter(newcharacter);
    @:privateAccess
    var tex:FlxFramesCollection = Paths.getSparrowAtlas(precache._data.assetPath, 'shared');
    /**
     * a passthrough to the playstate code....port this to only be in here eventually.
     */

    switch (targetName)
    {
      case 'boyfriend' | 'bf' | 'player':
        PlayState.instance.ResetCharacters(newcharacter, 'bf');

      case 'dad' | 'opponent':
        PlayState.instance.ResetCharacters(newcharacter, 'dad');

        // case 'both' | 'all':
        //   PlayState.instance.regenStrumlines('dad', styleswap);
        //   PlayState.instance.regenStrumlines('bf', styleswap);
        //   PlayState.instance.regenNoteData(FlxG.sound.music.time);
    }
  }

  /**
   * Retrieves the chart editor schema for this song event type.
   * @return The schema, or null if this event type does not have a schema.
   */
  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'target',
        title: 'Target',
        type: SongEventFieldType.STRING,
        defaultValue: 'bf',
      },
      {
        name: 'character',
        title: 'New Character',
        type: SongEventFieldType.STRING,
        defaultValue: 'dad',
      }
    ]);
  }

  /**
   * Retrieves the asset path to the icon this event type should use in the chart editor.
   * To customize this, override getIconPath().
   */
  public override function getIconPath():String
  {
    return 'ui/chart-editor/events/default';
  }

  /**
   * Retrieves the human readable title of this song event type.
   * Used for the chart editor.
   * @return The title.
   */
  public override function getTitle():String
  {
    return 'Character Swap';
  }
}
