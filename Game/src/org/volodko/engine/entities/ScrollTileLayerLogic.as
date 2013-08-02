/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 27.04.12
 * Time: 17:41
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;
import flash.geom.Rectangle;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;

public class ScrollTileLayerLogic extends TileLayerLogic {

    private var xCoef:Number = 1;
    private var yCoef:Number = 1;
    private var tempRect:Rectangle;
    private var tempOX:int;
    private var tempOY:int;
    private var coefOX:Number;
    private var coefOY:Number;
    private var addX:Number;
    private var addY:Number;

    public function ScrollTileLayerLogic(entity:Entity, tileXML:XMLList, sortIndex:Point, xCoef:Number, yCoef:Number) {
        this.xCoef = xCoef;
        this.yCoef = yCoef;
        super(entity, tileXML, sortIndex);
        trace("ScrollTileLayerLogic", xCoef, yCoef);
    }


    override public function updateTiles():void {

        //super.updateTiles();
        //
        tempOX = tilemap.getOffsetX();
        tempOY = tilemap.getOffsetY();
        coefOX = tempOX*xCoef;
        coefOY = tempOY*yCoef;
        addX = tempOX - coefOX;
        addY = tempOY - coefOY;
        tempRect = tilemap.getCustomCellRect(coefOX, coefOY);
        //
        x = tempRect.x; y = tempRect.y;
        xEnd = tempRect.width; yEnd = tempRect.height;
        //
        for(var yy:int = y; yy <= yEnd;++yy)
        {
            for(var xx:int = x; xx <= xEnd;++xx) {
                tileID = tiles[yy][xx];
                if(tileID > 0) {
                    position.x = xx * cellWidth + addX;
                    position.y = yy * cellHeight + addY;
                    tileBD = tileset.getTile(tileID);
                    if(tileBD != null) tilemap.renderSorted(tileBD, position.clone(), sortIndex);
                }
            }
        }
    }

}
}
