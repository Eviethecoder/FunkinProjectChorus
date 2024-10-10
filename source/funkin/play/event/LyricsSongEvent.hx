package funkin.play.event;

// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

/**
 * This class represents a handler for a type of song event.
 * It is used by the ScriptedSongEvent class to handle user-defined events.
 */
class LyricsSongEvent extends SongEvent
{
  public function new()
  {
    super('Lyrics');
  }

  /**
   * Handles a song event that matches this handler's ID.
   * @param data The data associated with the event.
   */
  public override function handleEvent(data:SongEventData):Void
  {
    var lyrics = data.getString('lyric');
    var duration = data.getFloat('duration');
    var easingtype = data.getString('ease');
    /**
     * a passthrough to the playstate code....port this to only be in here eventually.
     */

    PlayState.instance.makelyrics(lyrics, duration, easingtype);
  }

  /**
   * Retrieves the chart editor schema for this song event type.
   * @return The schema, or null if this event type does not have a schema.
   */
  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'lyric',
        title: 'lyrics:',
        type: SongEventFieldType.STRING,
        defaultValue: 'pepepopo',
      },
      {
        name: 'duration',
        title: 'Duration',
        defaultValue: 4.0,
        step: 0.5,
        type: SongEventFieldType.FLOAT,
        units: 'steps'
      },

      {
        name: 'ease',
        title: 'ease',
        type: SongEventFieldType.STRING,
        defaultValue: 'linear',
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
    return 'Lyrics';
  }
}
