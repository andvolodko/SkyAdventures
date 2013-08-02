package org.volodko.engine.cache
{
	public class ChildData
	{	
		public var name:String;
		public var x:int;
		public var y:int;
		public var width:Number;
		public var height:Number;
		public var rotation:Number;
		//
		public function ChildData(nameLoc:String, xLoc:int, yLoc:int, widthLoc:Number, heightLoc:Number, rotationLoc:Number) {
			name = nameLoc;
			x = xLoc;
			y = yLoc;
			width = widthLoc;
			height = heightLoc;
			rotation = rotationLoc;
		}
		
		public function clone():ChildData
		{
			return new ChildData(name, x, y, width, height, rotation);
		}
		
	}

}