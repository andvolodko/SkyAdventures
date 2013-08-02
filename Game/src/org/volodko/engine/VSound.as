package org.volodko.engine
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

import org.volodko.engine.components.PixelRender;

/**
	 * This is the universal flixel sound object, used for streaming, music, and sound effects.
	 */
	public class VSound
	{
		private var active:Boolean;
		/**
		 * Whether or not this sound should be automatically destroyed when you switch states.
		 */
		public var survive:Boolean;
		/**
		 * Whether the sound is currently playing or not.
		 */
		public var playing:Boolean;
		/**
		 * The ID3 song name.  Defaults to null.  Currently only works for streamed sounds.
		 */
		public var name:String;
		/**
		 * The ID3 artist name.  Defaults to null.  Currently only works for streamed sounds.
		 */
		public var artist:String;
		
		protected var _init:Boolean;
		protected var _sound:Sound;
		protected var _channel:SoundChannel;
		protected var _transform:SoundTransform;
		protected var _position:Number;
		protected var _volume:Number;
		protected var _volumeAdjust:Number;
		public var _looped:Boolean;
		protected var _radius:Number;
		protected var _pan:Boolean;
		protected var _fadeOutTimer:Number;
		protected var _fadeOutTotal:Number;
		protected var _pauseOnFadeOut:Boolean;
		protected var _fadeInTimer:Number;
		protected var _fadeInTotal:Number;
		protected var _point2:Point;
		//
		protected var posData:PixelRender;
		protected var x:int;
		protected var y:int;
		protected var soundClass:Class;
		/**
		 * The Sound constructor gets all the variables initialized, but NOT ready to play a sound yet.
		 */
		public function GLBSound()
		{
			_point2 = new Point();
			_transform = new SoundTransform();
			init();
		}
		/**
		 * An internal function for clearing all the variables used by sounds.
		 */
		protected function init():void
		{
			_transform.pan = 0;
			_sound = null;
			_position = 0;
			_volume = 1.0;
			_volumeAdjust = 1.0;
			_looped = false;
			_radius = 0;
			_pan = false;
			_fadeOutTimer = 0;
			_fadeOutTotal = 0;
			_pauseOnFadeOut = false;
			_fadeInTimer = 0;
			_fadeInTotal = 0;
			active = false;
			playing = false;
			name = null;
			artist = null;
		}
		public function setPosData(posDataLoc:PixelRender):void {
			posData = posDataLoc;
			setPos(posData.getOffsetPos().x, posData.getOffsetPos().y);
		}
		public function getSoundClass():Class {
			return soundClass;
		}
		/**
		 * An internal function for set position for sound
		 */
		public function setPos(xPos:int, yPos:int):void
		{
			x = xPos;
			y = yPos;
			var dist_x:Number = ((xPos - GLB.width/2) / GLB.width);
			var dist_y:Number = ((yPos - GLB.height/2) / GLB.height);
			var vol_x:Number = (1 - Math.abs(dist_x));
			var vol_y:Number = (1 - Math.abs(dist_y));
			var vol:Number = Math.min(1, Math.max(0, Math.min(vol_x, vol_y)));
			if (vol <= 0) return;
			var pan:Number = dist_x * 2.5; // 2.5 - pan modificator
			pan = Math.min(1, Math.max( -1, pan));
			_transform.pan = pan;
			//_transform.volume = vol;
			volume = vol;
			
		}
		/**
		 * One of two main setup functions for sounds, this function loads a sound from an embedded MP3.
		 * 
		 * @param	EmbeddedSound	An embedded Class object representing an MP3 file.
		 * @param	Looped			Whether or not this sound should loop endlessly.
		 * 
		 * @return	This <code>Sound</code> instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadEmbedded(EmbeddedSound:Class, Looped:Boolean=false):Sound
		{
			stop();
			init();
			soundClass = EmbeddedSound;
			_sound = new EmbeddedSound;
			//NOTE: can't pull ID3 info from embedded sound currently
			_looped = Looped;
			updateTransform();
			active = true;
			return _sound;
		}
		
		public function getSound():Sound {
			return _sound;
		}
		
		/**
		 * Call this function to play the sound.
		 */
		public function play():void
		{
			if(_position < 0)
				return;
			if(_looped)
			{
				if(_position == 0)
				{
					if(_channel == null)
						_channel = _sound.play(0,9999,_transform);
					if(_channel == null)
						active = false;
				}
				else
				{
					_channel = _sound.play(_position,0,_transform);
					if(_channel == null)
						active = false;
					else
						_channel.addEventListener(Event.SOUND_COMPLETE, looped);
				}
			}
			else
			{
				if(_position == 0)
				{
					if(_channel == null)
					{
						_channel = _sound.play(0,0,_transform);
						if(_channel == null)
							active = false;
						else
							_channel.addEventListener(Event.SOUND_COMPLETE, stopped);
					}
				}
				else
				{
					_channel = _sound.play(_position,0,_transform);
					if(_channel == null)
						active = false;
				}
			}
			playing = (_channel != null);
			_position = 0;
		}
		
		/**
		 * Call this function to pause this sound.
		 */
		public function pause():void
		{
			if(_channel == null)
			{
				_position = -1;
				return;
			}
			_position = _channel.position;
			_channel.stop();
			if(_looped)
			{
				while(_position >= _sound.length)
					_position -= _sound.length;
			}
			_channel = null;
			playing = false;
		}
		
		/**
		 * Call this function to stop this sound.
		 */
		public function stop():void
		{
			_position = 0;
			if(_channel != null)
			{
				_channel.stop();
				stopped();
			}
		}
		
		/**
		 * Call this function to make this sound fade out over a certain time interval.
		 * 
		 * @param	Seconds			The amount of time the fade out operation should take.
		 * @param	PauseInstead	Tells the sound to pause on fadeout, instead of stopping.
		 */
		public function fadeOut(Seconds:Number,PauseInstead:Boolean=false):void
		{
			_pauseOnFadeOut = PauseInstead;
			_fadeInTimer = 0;
			_fadeOutTimer = Seconds;
			_fadeOutTotal = _fadeOutTimer;
		}
		
		/**
		 * Call this function to make a sound fade in over a certain
		 * time interval (calls <code>play()</code> automatically).
		 * 
		 * @param	Seconds		The amount of time the fade-in operation should take.
		 */
		public function fadeIn(Seconds:Number):void
		{
			_fadeOutTimer = 0;
			_fadeInTimer = Seconds;
			_fadeInTotal = _fadeInTimer;
			play();
		}
		
		/**
		 * Set <code>volume</code> to a value between 0 and 1 to change how this sound is.
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * @private
		 */
		public function set volume(Volume:Number):void
		{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
			updateTransform();
		}
		
		/**
		 * Internal function that performs the actual logical updates to the sound object.
		 * Doesn't do much except optional proximity and fade calculations.
		 */
		protected function updateSound():void
		{
			if(_position != 0)
				return;
			
			var radial:Number = 1.0;
			var fade:Number = 1.0;
			
			//Distance-based volume control
			/* if(_core != null)
			{
				var _point:Point = new Point();
				var _point2:Point = new Point();
				getScreenXY(_point2);
				var dx:Number = _point.x - _point2.x;
				var dy:Number = _point.y - _point2.y;
				radial = (_radius - Math.sqrt(dx*dx + dy*dy))/_radius;
				if(radial < 0) radial = 0;
				if(radial > 1) radial = 1;
				
				if(_pan)
				{
					var d:Number = -dx/_radius;
					if(d < -1) d = -1;
					else if(d > 1) d = 1;
					_transform.pan = d;
				}
			} */
			
			//Cross-fading volume control
			if(_fadeOutTimer > 0)
			{
				_fadeOutTimer -= GLB.elapsed;
				if(_fadeOutTimer <= 0)
				{
					if(_pauseOnFadeOut)
						pause();
					else
						stop();
				}
				fade = _fadeOutTimer/_fadeOutTotal;
				if(fade < 0) fade = 0;
			}
			else if(_fadeInTimer > 0)
			{
				_fadeInTimer -= GLB.elapsed;
				fade = _fadeInTimer/_fadeInTotal;
				if(fade < 0) fade = 0;
				fade = 1 - fade;
			}
			
			_volumeAdjust = radial*fade;
			updateTransform();
		}

		/**
		 * The basic game loop update function.  Just calls <code>updateSound()</code>.
		 */
		public function update():void
		{
			if (posData) {
				var newPos:Object =  posData.getOffsetPos();
				if (newPos.x != x || newPos.y != y) setPos(newPos.x ,newPos.y);
			}
			updateSound();
		}
		
		/**
		 * The basic class destructor, stops the music and removes any leftover events.
		 */
		public function destroy():void
		{
			if(active)
				stop();
		}
		
		/**
		 * An internal function used to help organize and change the volume of the sound.
		 */
		internal function updateTransform():void
		{
			_transform.volume = Number(!GLB.mute)*GLB.volume*_volume*_volumeAdjust;
			if(_channel != null)
				_channel.soundTransform = _transform;
		}
		
		/**
		 * An internal helper function used to help Flash resume playing a looped sound.
		 * 
		 * @param	event		An <code>Event</code> object.
		 */
		protected function looped(event:Event=null):void
		{
		    if (_channel == null)
		    	return;
	        _channel.removeEventListener(Event.SOUND_COMPLETE,looped);
	        _channel = null;
			play();
		}

		/**
		 * An internal helper function used to help Flash clean up and re-use finished sounds.
		 * 
		 * @param	event		An <code>Event</code> object.
		 */
		protected function stopped(event:Event=null):void
		{
			if(!_looped)
	        	_channel.removeEventListener(Event.SOUND_COMPLETE,stopped);
	        else
	        	_channel.removeEventListener(Event.SOUND_COMPLETE,looped);
	        _channel = null;
	        active = false;
			playing = false;
		}
		
		/**
		 * Internal event handler for ID3 info (i.e. fetching the song name).
		 * 
		 * @param	event	An <code>Event</code> object.
		 */
		protected function gotID3(event:Event=null):void
		{
			if(_sound.id3.songName.length > 0)
				name = _sound.id3.songName;
			if(_sound.id3.artist.length > 0)
				artist = _sound.id3.artist;
			_sound.removeEventListener(Event.ID3, gotID3);
		}
	}
}
