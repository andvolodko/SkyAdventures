/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 22.04.12
 * Time: 4:10
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;
import flash.geom.Rectangle;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;

import org.volodko.engine.Entity;
import org.volodko.engine.physic.Physic;
import org.volodko.engine.threads.Threads;

public class BricksLayerLogic extends XMLLayerLogic {
    
    private const BRICKS_COUNT:int = 100;
    //
    private var threads:Threads;
    private var bricks:Vector.<Body> = new Vector.<Body>();
    //
    private var physic:Physic;
    private var space:Space;
    //
    private var cellWidth2:int;
    private var cellHeight2:int;

    public function BricksLayerLogic(entity:Entity, tileXML:XMLList, sortIndex:Point) {
        super(entity, tileXML, sortIndex);
    }

    override public function init():void {
        super.init();
        //
        threads = Threads(engine.getModule(Threads));
        physic = Physic(engine.getModule(Physic));
        //
        cellWidth2 = cellWidth/2;
        cellHeight2 = cellHeight/2;
        //
        space = physic.getSpace();
        //
        threads.addThread(bricksCreateThread, 0.5, bricksCreated, "Physic bricks")
        disable();
        //
        entity.addPostUpdate(updateBricks);
    }

    private function bricksCreated():void {
        trace("bricksCreated");
        enable();
    }
    
    private function bricksCreateThread():Boolean {
        if(bricks.length >= BRICKS_COUNT) return false; //Stop
        bricks.push(getBrick());
        return true;//Continue
    }

    private function getBrick():Body {
        var brick:Body = new Body(BodyType.KINEMATIC);
        brick.shapes.add(new Polygon(Polygon.box(tilemap.getCellWidth(), tilemap.getCellHeight())));
        brick.align();
        return brick;
    }

    override public function update():void {
        super.update();
        if(!enabled) return;
        //
        //return;
        //trace("tileLayerUpdate");
        //

    }
    private function updateBricks():void {
        if(!enabled) return;
        //
        cellRect = tilemap.getCellRect();
        //
        var brickIndex:int = 0;
        //
        for(var yy:int = cellRect.y; yy < cellRect.height;++yy)
        {
            for(var xx:int = cellRect.x; xx < cellRect.width;++xx) {
                tileID = tiles[yy][xx];
                if(tileID > 0 && brickIndex < BRICKS_COUNT) {
                    var brick:Body = bricks[brickIndex];
                    brick.space = space;
                    brick.position.x = xx * cellWidth + cellWidth2;
                    brick.position.y = yy * cellHeight + cellHeight2;
                    ++brickIndex;
                }

            }
        }
    }

}
}
