package org.volodko.engine.components {

import flash.geom.Point;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.TileMap;

public class Parallax extends Component {
    private var scrollSizeX:Number;
    private var scrollSizeY:Number;
    private var startPoint:Point;
    private var graphic:Graphic;
    private var tilemap:TileMap;

    public function Parallax(entityLoc:Entity, scrollSizeX:Number, scrollSizeY:Number, graphic:Graphic = null) {
        this.scrollSizeX = scrollSizeX;
        this.scrollSizeY = scrollSizeY;
        this.graphic = graphic;
        super(entityLoc);
    }

    override public function init():void {
        super.init();
        //
        if (!graphic) graphic = Graphic(getComponent(Graphic));
        tilemap = TileMap(GLB.engine.getModule(TileMap));
        //
        startPoint = new Point(graphic.x, graphic.y);
    }

    override public function update():void {
        super.update();
        //Var 1
        graphic.x = startPoint.x + tilemap.getOffsetX() * scrollSizeX;
        graphic.y = startPoint.y + tilemap.getOffsetY() * scrollSizeY;

    }
}

}