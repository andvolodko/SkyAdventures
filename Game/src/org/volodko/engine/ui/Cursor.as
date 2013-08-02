package org.volodko.engine.ui
{
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.ui.Mouse;
import flash.ui.MouseCursorData;

import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.Module;
import org.volodko.engine.MsgVO;

public class Cursor extends Module {
        //
		static public const CURSOR_POINTER:String = "pointer";
		static public const CURSOR_FINGER:String = "finger";
		static public const CURSOR_FINGER_ON:String = "finger_on";
		static public const CURSOR_TAKE:String = "take";
		static public const CURSOR_HAND:String = "hand";
		//
		private var nativeCursor:Boolean = false;
		private var isFocus:Boolean = true;
        private var cursorGr:CursorsGr = new CursorsGr();
		//
		public function Cursor(customCursor:Boolean) {
			super();
			if (!customCursor) return;
			// Flash 10.2 support
			if (Mouse.supportsNativeCursor) {
				//trace("Mouse.supportsNativeCursor");
                nativeCursor = true;
				addNativeCursor();
			} else {
                //Add movie clip as cursor
                Mouse.hide();
                GLB.stage.addChild(cursorGr);
            }
            //Set default cursor
            setCursor(CURSOR_POINTER);
            //
            update();
            //
            register(signalListener, GroupsVO.MOUSE);
		}
		
		private function addNativeCursor():void 
		{
			var cursors:Object = {};
			cursors[CURSOR_FINGER] = null;
			cursors[CURSOR_FINGER_ON] = null;
			cursors[CURSOR_HAND] = null;
			cursors[CURSOR_POINTER] = null;
			cursors[CURSOR_TAKE] = null;
			
			for (var val:* in cursors) {
				//trace( val, cursors[val] );
				cursors[val] = new MouseCursorData();
				cursorGr.gotoAndStop(val);
				var tmpBD:BitmapData = new BitmapData(cursorGr.width, cursorGr.height, true, 0);
				tmpBD.draw(cursorGr);
				cursors[val].data = (new Vector.<BitmapData>());
				cursors[val].data.push(tmpBD);
				cursors[val].frameRate = 1;
				Mouse.registerCursor(val, cursors[val]);
			}
		}
		override public function update():void {
			super.update();
            if(!nativeCursor) {
                GLB.stage.setChildIndex( cursorGr, GLB.stage.numChildren - 1 );
                cursorGr.x = GLB.mx;
                cursorGr.y = GLB.my;
            }
		}
		/*
		 * Use: setCursor("pointer"); "finger", "finger_on", "take", "hand"
		 */
		public function setCursor(type:String):void {
			if (nativeCursor) Mouse.cursor = type;
            else cursorGr.gotoAndStop(type);
		}

		public function focus():void 
		{
			isFocus = true;
		}
		public function unFocus():void 
		{
			isFocus = false;
		}
		
		/* ------------------------------------- Signals listener --------------------------------------- */
		private function signalListener(msg:String, data:Object):void
		{
			switch(msg) {

                /*
				case Msg.STATE:
					setCursor(Cursor.CURSOR_POINTER);
				break;
				
				// For cursor
				case "cursor_show": activate(); break;
				case "cursor_hide": disable(); break;
				*/

				//For buttons
				case MsgVO.BUTTON_OUT: setCursor(Cursor.CURSOR_POINTER); break;
				case MsgVO.BUTTON_UP: setCursor(Cursor.CURSOR_FINGER); break;
				case MsgVO.BUTTON_DOWN: setCursor(Cursor.CURSOR_FINGER_ON); break;
				case MsgVO.BUTTON_OVER: setCursor(Cursor.CURSOR_FINGER); break;

                /*
				// For drag object
				case Msg.DRAG_OUT: setCursor(Cursor.CURSOR_POINTER); break;
				case Msg.DRAG_UP: setCursor(Cursor.CURSOR_HAND); break;
				case Msg.DRAG_DOWN: setCursor(Cursor.CURSOR_TAKE); break;
				case Msg.DRAG_OVER: setCursor(Cursor.CURSOR_HAND); break;
				//
				     */
				
			}
		}
	}
}