/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 29.04.12
 * Time: 2:25
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities.triggers {
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Vec2;
import nape.phys.BodyType;

import org.volodko.engine.components.physic.PhysicComponent;
import org.volodko.engine.entities.XMLObject;

public class Trigger extends XMLObject {

    private var sortIndex:int;
    private var type:String;
    private var group:String;
    private var reload:Number;
    private var task:String;
    private var times:int;
    //
    private var body:PhysicComponent;

    public function Trigger(object:XML, sortIndex:int) {
        this.sortIndex = sortIndex;
        super(object);
    }

    override public function init():void {
        super.init();
        //
        group = object.properties.property.(@name == "group").@value;
        reload = object.properties.property.(@name == "reload").@value;
        task = object.properties.property.(@name == "task").@value;
        times = object.properties.property.(@name == "times").@value;
        type = object.properties.property.(@name == "type").@value;
        //
        addComponent(body = new PhysicComponent(this, BodyType.STATIC));
        //
        switch (task) {
            case TriggerVO.TASK_SHAKE:
                addComponent(new ShakeTrigger(this, type));
                break;
            default:
                trace("ERROR: trigger without type ! " + object.@name);
        }
        //
        initComponents();
        //Configure coms
        body.setPosition(object.@x, object.@y);
        //
        if(object.polygon != undefined) {
            //trace("has polygon");
            body.addPolygone(getPoints(object.polygon.@points));
        } else {
            //trace("has'nt polygon");
            body.addRectangle(0,0, object.@width, object.@height);
        }
        body.addToSpace();

    }

    private function getPoints(pointsStr:String):GeomPoly {
        var retVec:GeomPoly = new GeomPoly();
        var pointsArr:Array = pointsStr.split(TriggerVO.POINTS_DELIM);
        //trace("PStr", pointsStr);
        //trace("Parr", pointsArr);
        for(var i:int = 0;i < pointsArr.length;i++)
        {
            var pointVal:Array = pointsArr[i].split(TriggerVO.POINT_VAL_DELIM);
            trace(Number(pointVal[0]), Number(pointVal[1]));
            retVec.push(new Vec2(Number(pointVal[0]), Number(pointVal[1])));
        }
        return retVec;
    }
}
}
