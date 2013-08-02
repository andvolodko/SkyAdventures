package org.volodko.engine
{
import org.volodko.engine.components.PixelRender;

public class Sounds extends Module
	{
		static private const MUSIC_MENU:String = "menu_music";
		static private const MUSIC_GAME:String = "game_music";
		//
		private var sounds:Array;
		private var currentMusic:String;
		private var bgSound:VSound;
		private var canSFX:Boolean = true;
		private var canMusic:Boolean = true;
		//
		public function Sounds()
		{
			super();
			NNLG.sounds = this;
			sounds = [];
			register(signalListener);
		}
		public function muteMusic(fromUser:Boolean = true):void {
			if (bgSound) bgSound.pause();
			canMusic = false;
			sodata.music = false;
			if(fromUser) dispatch("stat_music_off");
		}
		public function unMuteMusic():void {
			canMusic = true;
			dispatch(currentMusic);
			sodata.music = true;
			dispatch("stat_music_on");
		}
		public function muteSounds(fromUser:Boolean = true):void {
			canSFX = false;
			for (var i:int = 0; i < sounds.length; ++i)
			{
				if(sounds[i] != bgSound) sounds[i].pause();
			}
			sodata.sounds = false;
			if(fromUser) dispatch("stat_sounds_off");
		}
		public function unMuteSounds():void {
			canSFX = true;
			for (var i:int = 0; i < sounds.length; ++i)
			{
				if(sounds[i]._looped) sounds[i].play();
			}
			sodata.sounds = true;
			dispatch("stat_sounds_on");
		}
		private function removeAllSounds():void {
			for (var i:int = 0; i < sounds.length; ++i)
			{
				if (sounds[i] != bgSound) {
					sounds[i].stop();
					sounds[i].destroy();
				}
			}
			sounds = [];
		}
		override public function update():void {
			super.update();
			for (var i:int = 0; i < sounds.length; ++i) 
			{
				sounds[i].update();
			}
			if (bgSound) bgSound.update();
		}
		/* ------------------------------------- Signals listener --------------------------------------- */
		private function signalListener(signalMessage:String, signalData:Object):void
		{
			switch(signalMessage) {
				// BG music
				case "menu_music":
					currentMusic = MUSIC_MENU;
					if (!canMusic) break;
					if (!bgSound) {
						bgSound = new VSound();
					} else bgSound.stop();
					bgSound.loadEmbedded(menu_music_snd, true);
					bgSound.play();
				break;
				case "game_music":
					currentMusic = MUSIC_GAME;
					if (!canMusic) break;
					if (!bgSound) {
						bgSound = new VSound();
					} else bgSound.stop();
					//
					var playSnd:Class = game_music_snd;
					bgSound.loadEmbedded(playSnd, true);
					bgSound.play();
				break;
				case "state":
					removeAllSounds();
					trace("remove All Sounds");
				break;
				// UI
				case "button_clicked": play(menu_click_snd); break;
				case Msg.SOUND_LEVEL_WIN: play(level_win_snd); break;
				case Msg.SOUND_LEVEL_LOSE: play(level_lose_snd); break;
				
				// From game objects
				case Msg.SOUND_HERO_DIE: play( hero_dead_snd, false, signalData.x, signalData.y ); break;
				case Msg.SOUND_WEAPON10_WORK_START: play( weapon10_shoot_work_snd, true, 0, 0, PixelRender(signalData) ); break;
				case Msg.SOUND_WEAPON10_WORK_STOP: stopSound(weapon10_shoot_work_snd); break;

			}
		}
		
		private function stopSound(sndClass:Class):void
		{
			for (var i:int = 0; i < sounds.length; ++i)
			{
				if (sounds[i].getSoundClass() == sndClass) {
					VSound(sounds[i]).stop();
					VSound(sounds[i]).destroy();
				}
			}
		}
		
		private function play(sndClass:Class, looped:Boolean = false, xPos:int=-1000, yPos:int=-1000, pos:PixelRender = null):void
		{
			var tmpS:VSound = new VSound();
			tmpS.loadEmbedded(sndClass, looped);
			if (xPos > -1000 || yPos > -1000) {
				tmpS.setPos(xPos, yPos);
			}
			if (pos) tmpS.setPosData(pos);
			if (canSFX) tmpS.play();
			sounds.push(tmpS);
		}
		
	}

}