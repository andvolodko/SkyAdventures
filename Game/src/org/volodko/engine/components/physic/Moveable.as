package org.volodko.engine.components.physic
{
import org.volodko.engine.Entity;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.cache.ClipData;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.physic.PhysicObject;
	import flash.geom.Point;
	import nape.constraint.AngleJoint;
	import nape.constraint.DistanceJoint;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;

	public class Moveable extends PhysicComponent 
	{
		private var physicObject:PhysicObject;
		private var joint:DistanceJoint;
		private var pos:Point;
		
		public function Moveable(entityLoc:Entity, type:BodyType = null, graphic:Graphic = null, userType:Object = null, material:Material = null, preInit:Boolean = true)
		{
			if(!type) type = BodyType.DYNAMIC;
			super(entityLoc, type, graphic, userType, Material.ice(), preInit);
			allowedRotation = true;
			
		}
		override public function init():void {
			super.init();
			//
            CONFIG::debug {
                if(!graphic) trace("ERROR: No graphic in moveable "+entity);
            }
            //
			physicObject = PhysicObject(getComponent(PhysicObject));
			//
            var cd:ChildData = graphic.getChildData(PhysicVO.PHYSIC_MOVE_NAME);
			var radius:Number = cd.width/2;
            var jd:ChildData = graphic.getChildData(PhysicVO.PHYSIC_JOINT_NAME);
			//var jointPos:Vec2 = new Vec2(jd.x + physicObject.x, jd.y + physicObject.y);
			var jointPos:Vec2 = new Vec2(graphic.x + jd.x, graphic.y + jd.y);
			//pos = pos.add(graphic.getPosPoint());
			//pos.x += radius;
			//
			material.rollingFriction = 10000;
			material.dynamicFriction = 10000;
			material.staticFriction = 10000;
			//
            x =  graphic.x + cd.x;
            y =  graphic.y + cd.y;
            addCircleShape(0,0, radius);
            setMass(2);
			addToSpace();
			//
			var body2:Body = physicObject.getBody();
			var anchor:Vec2 = body.worldToLocal(jointPos);
			var anchor2:Vec2 = body2.worldToLocal(jointPos);
			//var anchor2:Vec2 = body2.localCOM.copy();
			//
			//joint = new PivotJoint(body, body2, anchor, anchor2);
			joint = new DistanceJoint(body, body2, anchor, anchor2, 0,0);
			//joint.damping = 0;
			//joint.frequency = 0;
			joint.ignore = true;
			joint.stiff = true;
			joint.space = space;
		}
		override public function update():void {
			super.update();
		}

        public function move(xVal:Number = 0, yVal:Number = 0):void {
            physicObject.applyForce(xVal, yVal);
        }


		override public function allowMovement(val:Boolean):void {
			super.allowMovement(val);
			/* switch(val) {
				case true:
					joint.active = true;
				break;
				case false:
					joint.active = false;
				break;
			} */
		}
		
		override public function enable():void {
			super.enable();
			joint.space = space;
		}
		
		override public function disable():void {
			super.disable();
			joint.space = null;
		}
		
		override public function remove():void {
			joint.space = null;
			super.remove();
		}
		
	}

}