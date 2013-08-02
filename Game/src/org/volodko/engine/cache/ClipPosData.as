package org.volodko.engine.cache
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public class ClipPosData 
	{
		//
		public var className:String;
		public var childNames:Vector.<ChildHolder>;
		//
		public function ClipPosData(classNameLoc:String) 
		{
			className = classNameLoc;
			childNames = new Vector.<ChildHolder>();
		}
		
		public function hasName(chName:String):Boolean
		{
			for (var i:int = 0; i < childNames.length; ++i) 
			{
				if (childNames[i].name == chName) return true;
			}
			return false;
		}
		
		public function addName(clip:MovieClip, chName:String):void 
		{
			childNames.push( new ChildHolder(chName, getPositions(clip, chName) ) );
		}
		
		private function getPositions(clip:MovieClip, childName:String):Vector.<ClipPos> 
		{
			var retVec:Vector.<ClipPos> = new Vector.<ClipPos>();
			//retVec.push( new ClipPos(0, 0) ); // 0 frame
			var currFrame:int = clip.currentFrame;
			for (var j:int = 1; j <= clip.totalFrames; ++j) 
			{
				clip.gotoAndStop(j);
				retVec.push(new ClipPos(0, 0));
				for (var i:int = 0; i < clip.numChildren; ++i) 
				{
					var tmpChild:DisplayObject = clip.getChildAt(i);
					if (tmpChild.name == childName) {
							retVec[retVec.length - 1].x = tmpChild.x;
							retVec[retVec.length - 1].y = tmpChild.y;
						}
				}
			}
			clip.gotoAndStop(currFrame);
			return retVec;
		}
		
	}

}

internal class ChildHolder {
	//
	public var name:String;
	public var positions:Vector.<ClipPos>;
	//
	public function ChildHolder(nameLoc:String, positionsLoc:Vector.<ClipPos>) 
	{
		name = nameLoc;
		positions = positionsLoc;
	}
	
}

internal class ClipPos {
	//
	public var x:Number;
	public var y:Number;
	//
	public function ClipPos(xLoc:Number, yLoc:Number) 
	{
		x = xLoc; y = yLoc;
	}
	public function toString():String {
		return x+";"+y;
	}
	
}