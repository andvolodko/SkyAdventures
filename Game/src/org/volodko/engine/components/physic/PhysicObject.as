package org.volodko.engine.components.physic
{

import flash.geom.Point;

import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import org.volodko.engine.Entity;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.components.Graphic;

	public class PhysicObject extends PhysicComponent 
	{
        private var translatePos:Point;

		public function PhysicObject(entityLoc:Entity, type:BodyType, graphic:Graphic = null, userType:Object = null, material:Material = null, preInit:Boolean = true) 
		{
			super(entityLoc, type, graphic, userType, material, preInit);
			allowedRotation = false;
		}
		
		override public function init():void {
			super.init();
			//
			if (preInit) {
				if (graphic.haveChild(PhysicVO.PHYSIC_OBJECT_NAME)) parseBitmap(); else {
                    CONFIG::debug {
                        trace("ERROR: Physic object have not physic child ! "+entity);
                    }
                }
				//else body.shapes.add(new Polygon(Polygon.rect(0, 0, graphic.getWidth(), graphic.getHeight()), material, interactionFilter));
				var cd:ChildData = graphic.getChildData(PhysicVO.PHYSIC_OBJECT_NAME);
                translatePos = new Point(cd.x, cd.y);
                addToSpace();
                //
                x = graphic.x + translatePos.x;
                y = graphic.y + translatePos.y;
                setMass(1);
                //update();
			}
		}

		override public function update():void {
			super.update();
			//
			if (!enabled) return;
			switch(type) {
				case BodyType.DYNAMIC:
					if(body.allowMovement) {
                       graphic.x = x - translatePos.x;
                       graphic.y = y - translatePos.y;
                    }
					if (body.allowRotation) {
						//graphic.setRotation(LoDMath.radiansToDegrees(normaliseAngle(body.rotation)));
                        graphic.rotation = getRotation();
					}
				break;
			}
		}
	}

}