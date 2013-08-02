package org.volodko.engine.components {
import flash.geom.Point;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.TileMap;
import org.volodko.engine.VBitmapData;

public class PixelRender extends Component {
    //
    private var graphic:Graphic;
    private var tileMap:TileMap;
    private var debugBD:VBitmapData;
    private var groupNum:int;
    private var sortPos:Point;

    public function PixelRender(entityLoc:Entity, groupNum:int = 0, graphic:Graphic = null) {
        this.groupNum = groupNum;
        this.graphic = graphic;
        super(entityLoc);
    }

    override public function init():void {
        super.init();
        //
        if (!graphic) graphic = Graphic(getComponent(Graphic));
        tileMap = TileMap(GLB.engine.getModule(TileMap));
        //
        setGroupNum(groupNum);
        //Debug
        CONFIG::debug {
            debugBD = new VBitmapData(10, 10, true, 0xffff0000);
        }
        //
        entity.addPostUpdate(postUpdateFunc);
    }

    private function postUpdateFunc():void {
        if (!enabled) return;
        //
        if (graphic.visible) {
            //sortPos = graphic.getPositionPoint().clone();
            tileMap.renderSorted(graphic.getBD(), graphic.cachedPosition, sortPos, graphic.rotation, graphic.getRotationMargin());
            //
            CONFIG::debug {
                //Debug
                //var debugPoint:Point = graphic.getPositionPoint().clone();
                //map.graphicPost(debugBD, debugPoint, debugPoint);
            }

        }
        //map.graphicNow(graphic.getBD(), graphic.getPositionPoint());
    }

    override public function update():void {
        super.update();
        if (!enabled) return;
        //
    }

    //Set
    public function setGroupNum(groupNumLoc:int):void {
        groupNum = groupNumLoc;
        sortPos = new Point(TileMap.getSortFromGroup(groupNum), 0);
    }

}

}