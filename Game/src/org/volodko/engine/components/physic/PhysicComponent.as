package org.volodko.engine.components.physic {
import flash.geom.Point;

import nape.dynamics.Arbiter;
import nape.dynamics.InteractionFilter;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Mat23;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.cache.ClipData;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.physic.Physic;

public class PhysicComponent extends Component {
    //
    static protected const PI_2:Number = Math.PI / 2;
    static protected const SIMPLIFY_VALUE:Number = 2;
    //
    protected var graphic:Graphic;
    protected var physic:Physic;
    protected var space:Space;
    protected var body:Body;
    protected var type:BodyType;
    protected var userType:Object;
    protected var material:Material;
    //
    protected var preInit:Boolean = true;
    //
    protected var allowedRotation:Boolean = true;
    //
    public function PhysicComponent(entityLoc:Entity, type:BodyType, graphic:Graphic = null, userType:Object = null, material:Material = null, preInit:Boolean = true) {
        this.userType = userType;
        this.material = material;
        this.graphic = graphic;
        this.type = type;
        this.preInit = preInit;
        super(entityLoc);

    }

    override public function init():void {
        super.init();
        //
        if (!graphic) graphic = Graphic(getComponent(Graphic));
        physic = Physic(GLB.engine.getModule(Physic));
        space = physic.getSpace();
        //
        if (graphic) body = new Body(type, new Vec2(graphic.x, graphic.y));
        else body = new Body(type);
        body.userData = userType;
        body.allowRotation = allowedRotation;
    }

    public function addToSpace():void {
        body.space = space;
    }

    public function parseBitmap():void {
        CONFIG::debug {
            if (!graphic) trace("ERROR: No graphic in physic component " + entity);
        }
        var clipData:ClipData = graphic.getClipData();
        var geomList:GeomPolyList = clipData.physicBD[0];
        var cd:ChildData = graphic.getChildData(PhysicVO.PHYSIC_OBJECT_NAME);
        var vec:Vec2 = new Vec2(cd.x, cd.y);
        //trace(geomList.length);
        for (var i:int = 0; i < geomList.length; ++i) {
            var gp:GeomPoly = geomList.at(i);
            var poly:Polygon = new Polygon(gp, material);
            poly.translate(vec);
            body.shapes.add(poly);
        }
        body.align();
    }

    public function getUserType():Object {
        return userType;
    }

    public function removeShapes():void {
        body.shapes.clear();
    }

    public function addRectangle(x:Number, y:Number, width:Number, height:Number):void {
        body.shapes.add(new Polygon(Polygon.rect(x, y, width, height), material));
        //body.align();
    }

    public function addPolygone(points:GeomPoly):void {
        points.simplify(SIMPLIFY_VALUE);
        var gpl:GeomPolyList = points.convex_decomposition();
        for (var i:int = 0; i < gpl.length; ++i) {
            var gp:GeomPoly = gpl.at(i);
            var poly:Polygon = new Polygon(gp, material);
            body.shapes.add(poly);
        }
        //body.align();
    }

    public function addCircleShape(x:Number, y:Number, radius:Number):void {
        var circle:Circle = new Circle(radius, null, material);
        circle.translate(new Vec2(x, y));
        body.shapes.add(circle);
        //body.align();
        //body.setShapeMaterials(circle.material);
    }

    public function addCallback():void {
        //space.listeners.add()
        //
        //space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, boxcb,boxcb, boxer(0x00ff00)));
        //space.listeners.add(new InteractionListener(CbEvent.END,   InteractionType.COLLISION, boxcb,boxcb, boxer(0xff0000)));
        //function(cb:InteractionCallback)
        //
        //space.listeners.add(new PreListener(InteractionType.COLLISION,hexcb,hexcb,function(cb:PreCallback) {
        //return if(carb.contacts.length==0) PreFlag.IGNORE_ONCE; else PreFlag.ACCEPT_ONCE; }else return PreFlag.ACCEPT;
        //
    }

    public function allowRotation(value:Boolean):void {
        body.rotation = 0;
        body.torque = 0;
        body.angularVel = 0;
        body.allowRotation = value;
    }

    public function canRotation():Boolean {
        return body.allowRotation;
    }

    public function applyForce(forceX:Number, forceY:Number, pos:Point = null):void {
        forceX *= 100;
        forceY *= 100;
        //
        if (pos == null) body.applyLocalForce(Vec2.get(forceX, forceY));
        else body.applyLocalForce(Vec2.get(forceX, forceY), Vec2.get(pos.x, pos.y));
    }

    public function haveContactWithUserType(userType:Object):Boolean {
        var ret:Boolean = false;
        for (var i:int = 0; i < body.shapes.length; ++i) {
            var bodiesList:BodyList = space.bodiesInShape(body.shapes.at(i));
            for (var j:int = 0; j < bodiesList.length; ++j) {
                if (bodiesList.at(j).userData == userType) return true;
            }
        }
        return ret;
    }

    public function getContactBodiesByType(userType:Object):BodyList {
        var bodies:BodyList = new BodyList();
        //
        for (var i:int = 0; i < body.shapes.length; ++i) {
            var bodiesList:BodyList = space.bodiesInShape(body.shapes.at(i));
            for (var j:int = 0; j < bodiesList.length; ++j) {
                if (bodiesList.at(j).userData == userType)
                    bodies.push(bodiesList.at(j));
            }
        }
        return bodies;
    }

    /*
     *
     */
    public function getContactPoint(userType:Object):Point {
        for (var i:int = 0; i < body.arbiters.length; ++i) {
            var arb:Arbiter = body.arbiters.at(i);
            if (arb.isCollisionArbiter() && (arb.shape1.body.userData == userType || arb.shape2.body.userData == userType)) {
                return new Point(
                        arb.collisionArbiter.contacts.at(0).position.x,
                        arb.collisionArbiter.contacts.at(0).position.y);
            }
        }
        return null; //Error
    }

    public function getVelocityX():Number {
        return body.velocity.x;
    }

    public function getVelocityY():Number {
        return body.velocity.y;
    }

    public function setVelocity(velx:Number, vely:Number):void {
        body.velocity.y = vely;
        body.velocity.x = velx;
    }

    public function stopRotation():void {
        body.torque = 0;
        body.rotation = 0;
        body.angularVel = 0;
    }

    public function allowMovement(val:Boolean):void {
        body.allowMovement = val;
    }

    public function canMovement():Boolean {
        return body.allowMovement;
    }

    public function setPosition(posx:Number, posy:Number):void {
        body.position.x = posx;
        body.position.y = posy;
    }

    public function getPosition():Vec2 {
        return body.position.copy();
    }

    public function getGravity():Vec2 {
        return space.gravity;
    }

    public function get x():Number {
        return body.position.x;
    }

    public function get y():Number {
        return body.position.y;
    }

    public function set x(val:Number):void {
        body.position.x = val;
    }

    public function set y(val:Number):void {
        body.position.y = val;
    }

    public function getBody():Body {
        return body;
    }

    public function getSpace():Space {
        return space;
    }

    public function getRender():Graphic {
        return graphic;
    }

    public function setMass(value:Number):void {
        body.mass = value;
    }

    public function setFilter(newFilter:InteractionFilter):void {
        body.setShapeFilters(newFilter);
    }

    public function getRotation():Number {
        return body.rotation * 180 / Math.PI;
    }

    public function setRotation(val:Number):void {
        body.rotation = val;
        //return (body.rotation + body.zpp_inner.grotdelta) * 180 / Math.PI;
    }

    public function flipShapes():void {
        var mat:Mat23 = new Mat23(-1, 0, 0, 1, 0, 0);
        body.transformShapes(mat);
    }

    override public function enable():void {
        super.enable();
        body.space = space;
    }

    override public function disable():void {
        super.disable();
        body.space = null;
    }

    override public function remove():void {
        super.remove();
        body.space = null;
    }


    /*
     * Help fnc
     */
    private static function normaliseAngle(ang:Number):Number {
        var ang:Number = (ang + PI_2) % (PI_2);
        ang = (ang >= 0) ? ang : PI_2 + ang;
        return ang;
    }

    static private function binToDec(binArr:Array):int {
        if (binArr.length > 32) return 0; //Error
        var placeVal:Array = [2147483648, 1073741824, 536870912, 268435456, 134217728, 67108864, 33554432, 16777216, 8388608, 4194304, 2097152, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1];
        var res:int = 0;
        for (var i:int = 0; i < binArr.length; ++i) {
            res += binArr[i] * placeVal[i];
        }
        return res;
    }

}

}