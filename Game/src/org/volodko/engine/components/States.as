package org.volodko.engine.components 
{
	
	import flash.display.MovieClip;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;

public class States extends Component 
	{
		//
		private var state:int;
		private var oldState:int;
		private var anim:String;
		private var oldAnim:String;
		private var onAnimEndFunc:Function;
		private var tmpFunc:Function;
		//
		private var clip:MovieClip;
		private var graphic:Graphic;
		private var graphicSpec:Graphic;
		//
		private var animFrame:int = 0;
		//
		private var animElapsed:Number = 0;
		//
		private var stateFunctions:Vector.<Function>;
		//
		public function States(entityLoc:Entity, graphicSpec:Graphic= null) 
		{
			this.graphicSpec = graphicSpec;
			super(entityLoc);
		}
		override public function init():void {
			if (graphicSpec) graphic = graphicSpec;
			else graphic = Graphic(getComponent(Graphic));
			//
			stateFunctions = new Vector.<Function>();
			//clip = MovieClip(graphic.getClip());
		}
		override public function update():void {
			super.update();
			if (!enabled) return;
			animElapsed += GLB.elapsed; 
			if (anim && graphic.currLabel() != anim) {
				if (onAnimEndFunc != null) {
					tmpFunc = onAnimEndFunc;
					onAnimEndFunc = null;
					tmpFunc();
				}
				//trace(graphic.currLabel());
				if(graphic.currFrame()-animFrame == 1) graphic.goAndStop(anim);
				else graphic.goAndPlay(anim);
				//
				//graphic.goAndPlay(anim);
				//graphic.goAndStop(anim);
				//graphic.update();
			}
		}
		public function getgraphic():Graphic {
			return graphic;
		}
		public function getState():int {
			return state;
		}
		public function getOldState():int {
			return oldState;
		}
		public function setState(stateLoc:int):void {
			oldState = state;
			state = stateLoc;
			for (var i:int = 0; i < stateFunctions.length; ++i)
			{
				stateFunctions[i](stateLoc);
			}
		}
		public function getAnim():String {
			return anim;
		}
		public function getOldAnim():String
		{
			return oldAnim;
		}
		
		public function setAnim(animLoc:String):void {
			if (animLoc == anim) return;
			animElapsed = 0;
			oldAnim = anim;
			anim = animLoc;
			//
			graphic.goAndPlay(anim);
			animFrame = graphic.currFrame();
			graphic.update();
		}
		public function getAnimElapsed():Number {
			return animElapsed;
		}
		public function onAnimEnd(func:Function):void 
		{
			onAnimEndFunc = func;
		}
		public function getOnAnimEnd():Function {
			return onAnimEndFunc;
		}
		public function clearOnAnimEnd():void 
		{
			onAnimEndFunc = null;
		}
		public function addStateFunction(func:Function):void {
			stateFunctions.push(func);
		}
	}

}