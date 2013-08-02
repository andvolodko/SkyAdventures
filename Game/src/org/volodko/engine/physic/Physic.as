package org.volodko.engine.physic {
import flash.geom.Matrix;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;

import org.volodko.engine.CmdVO;
import org.volodko.engine.ConsoleCmd;

import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.Module;
import org.volodko.engine.MsgVO;

public class Physic extends Module {
    //
    static private const DEBUG_COLOR:uint = 0x00ffff;
    static private const DEBUG_ALPHA:Number = 0.5;
    //
    private var space:Space;
    //
    private var frameCoef:Number;
    //
    private var gravity:Vec2;
    //
    private var bitmapDebug:BitmapDebug;
    private var offsetXFunc:Function;
    private var offsetYFunc:Function;
    private var matrix:Matrix;
    //
    public function Physic(gravityX:Number, gravityY:Number) {
        gravity = new Vec2(gravityX, gravityY);
        super();
        init();
    }

    public function init():void {
        //
        trace("physic init");
        CONFIG::debug {
            dispatch(MsgVO.LOG, "Physic init", GroupsVO.DEBUG);
        }
        //
        //haxe.init(null);
        //
        frameCoef = 1 / GLB.stage.frameRate;
        //
        reset();
        //Test
        /* var body:Body = new Body(BodyType.KINEMATIC, new Vec2(250,250));
        body.shapes.add(new Circle(10));
        body.shapes.add(new Polygon(Polygon.box(10,10)));
        body.space = space;         */
        //
        CONFIG::debug {
            bitmapDebug = new BitmapDebug(GLB.width, GLB.height, DEBUG_COLOR, true);
            bitmapDebug.display.alpha = DEBUG_ALPHA;
            //bitmapDebug.drawBodyDetail = true;
            bitmapDebug.drawCollisionArbiters = true;
            bitmapDebug.drawConstraints = true;
            bitmapDebug.drawConstraintSprings = true;
            bitmapDebug.drawConstraintErrors = true;
            //bitmapDebug.drawFluidArbiters = true;
            //bitmapDebug.drawSensorArbiters = true;
            //bitmapDebug.drawShapeAngleIndicators = true;
            //bitmapDebug.drawShapeDetail = true;
            //
            GLB.stage.addChild(bitmapDebug.display);
        }
        //
        register(signalListener, GroupsVO.SYSTEM);
        CONFIG::debug {
            register(commandsListener, GroupsVO.DEBUG);
        }
    }

    override public function update():void {
        super.update();
        //
        updatePhysic();
    }

    public function updatePhysic():void {
        if (!enabled) return;
        //
        try {

            CONFIG::debug {
                bitmapDebug.clear();
            }
            //Step
            space.step(frameCoef, 10, 10);
            //Bitmap debug
            CONFIG::debug {
                if(offsetXFunc != null && offsetYFunc != null) {
                    //bitmapDebug.transform.reset();
                    if(matrix) {
                        bitmapDebug.transform.setAs(matrix.a,0,0,matrix.d,-offsetXFunc()*matrix.a+matrix.tx, -offsetYFunc()*matrix.d+matrix.ty);
                    } else {
                        bitmapDebug.transform.setAs(1,0,0,1,-offsetXFunc(), -offsetYFunc());
                    }
                }
                bitmapDebug.draw(space);
                bitmapDebug.flush();
            }

        } catch (e:Error) {
            trace("Physic update error " + e);
        }
        //space.step(frameCoef, 10, 10);
        //space.step(frameCoef, 10, 10);
    }

    public function setMatrix(matrix:Matrix):void {
        this.matrix = matrix;
    }

    public function getSpace():Space {
        return space;
    }

    public function reset():void {
        space = new Space(gravity /*, Broadphase.SWEEP_AND_PRUNE */);
    }

    /*
     public function rayCast(posX:Number, posY:Number, aX:Number, aY:Number):RayResultList 
     {
     return space.rayMultiCast( new Ray(new Vec2(posX, posY), new Vec2(aX - posX, aY - posY)), false, PhysicComponent.generateInterFilter(PhysicComponent.TYPE_RAY) );
     }

     public function rayCastOnce(posX:Number, posY:Number, aX:Number, aY:Number, rayType:int = 7):RayResult
     {
     return space.rayCast( new Ray(new Vec2(posX, posY), new Vec2(aX - posX, aY - posY)), false , PhysicComponent.generateInterFilter(rayType) );
     } */

    public function getBodiesInCircle(x:int, y:int, radius:int, type:int):BodyList {
        var bodyList:BodyList = space.bodiesInCircle(new Vec2(x, y), radius);
        for (var i:int = 0; i < bodyList.length; ++i) {
            if (bodyList.at(i).userData != type) {
                bodyList.remove(bodyList.at(i));
                i--;
            }

        }
        return bodyList;
    }

    public function getBodiesInPoint(x:int, y:int, type:int):BodyList {
        var bodyList:BodyList = space.bodiesUnderPoint(new Vec2(x, y));
        for (var i:int = 0; i < bodyList.length; i++) {
            if (bodyList.at(i).userData != type) {
                bodyList.remove(bodyList.at(i));
                i--;
            }

        }
        return bodyList;
    }

    /* ------------------------------------- Signals listener --------------------------------------- */
    private function signalListener(msg:String, data:Object):void {
        switch (msg) {
            case MsgVO.STATE:
                reset();
                break;
        }
    }
    //------------------------- Commands --------------------------
    private function commandsListener(msg:String, data:Object):void {
        switch (msg) {
            case MsgVO.CONSOLE_COMMAND:
                switch(ConsoleCmd(data).commandName) {
                    case CmdVO.PH_SHOW:
                        if(bitmapDebug) {
                            if(bitmapDebug.display.visible) bitmapDebug.display.visible = false;
                            else bitmapDebug.display.visible = true;
                        }
                        break;
                    case CmdVO.PH_CLEAR:
                        reset();
                        break;
                }
                break;
        }
    }

    //For scrolling debug bitmap
    public function setOffsetFunctions(offsetXFunc:Function, offsetYFunc:Function):void {
        this.offsetXFunc = offsetXFunc;
        this.offsetYFunc = offsetYFunc;
    }
}

}