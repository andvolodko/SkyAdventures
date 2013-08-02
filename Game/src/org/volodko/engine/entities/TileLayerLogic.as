/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 17.04.12
 * Time: 18:14
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;
import flash.geom.Rectangle;

import org.volodko.engine.Entity;
import org.volodko.engine.PixelDisplay;
import org.volodko.engine.Tileset;
import org.volodko.engine.VBitmapData;
import org.volodko.engine.components.Graphic;

public class TileLayerLogic extends XMLLayerLogic {

    protected var pixelDisplay:PixelDisplay;
    protected var tileset:Tileset;
    //
    protected var position:Point = new Point();
    //
    protected var x:int = 0;
    protected var xEnd:int = 0;
    protected var y:int = 0;
    protected var yEnd:int = 0;
    protected var tileBD:VBitmapData = null;
    //
    public function TileLayerLogic(entity:Entity, tileXML:XMLList, sortIndex:Point) {
        super(entity, tileXML, sortIndex);
    }


    override public function init():void {
        super.init();
        //
        pixelDisplay = PixelDisplay(engine.getModule(PixelDisplay));
        tileset = Tileset(engine.getModule(Tileset));
        //
        //trace(tiles.length, tiles[0].length, tiles[0][0], tiles[99][99]);
        //trace("tile layer init");
        //
        entity.addPostUpdate(updateTiles);
    }

    public function updateTiles():void {
        //
        x = cellRect.x; y = cellRect.y;
        xEnd = cellRect.width; yEnd = cellRect.height;
        //
        for(var yy:int = y; yy <= yEnd;++yy)
        {
            for(var xx:int = x; xx <= xEnd;++xx) {
                tileID = tiles[yy][xx];
                if(tileID > 0) {
                    position.x = xx * cellWidth;
                    position.y = yy * cellHeight;
                    tileBD = tileset.getTile(tileID);
                    if(tileBD != null) tilemap.renderSorted(tileBD, position.clone(), sortIndex);
                }
            }
        }
    }

    override public function update():void {
        super.update();
        //
        //return;
        //trace("tileLayerUpdate");
        //
    }
}
}
