/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 17.04.12
 * Time: 19:02
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.geom.Point;
import flash.geom.Rectangle;

import org.volodko.engine.cache.Cache;

public class Tileset extends Module {

    private var tileSets:Vector.<VBitmapData> = new Vector.<VBitmapData>(10000, true);
    private var cache:Cache;

    public function Tileset() {
        super();
        init();
    }

    private function init():void {
        //tileSets = new Vector.<VBitmapData>(10000, true);
        cache = Cache(GLB.engine.getModule(Cache));
    }

    public function addTileset(tilesetClass:Class, startID:int, width:int, height:int):void {
        //
        var tilesetBD:VBitmapData = cache.getClip(tilesetClass).framesBD[0];
        trace("TilesetBD", tilesetBD.width, tilesetBD.height, tilesetClass);
        //
        var tileID:int = startID;
        var tilesW:int = tilesetBD.width/width;
        var tilesH:int = tilesetBD.height/height;
        //
        var tempRect:Rectangle = new Rectangle(0,0,width, height);
        var tempPos:Point = new Point(0,0);
        //
        for(var yy:int = 0; yy < tilesH; ++yy) {
            for(var xx:int = 0; xx < tilesW; ++xx) {
                tileSets[tileID] = new VBitmapData(width, height);
                tempRect.x = width * xx; tempRect.y = height * yy;
                tileSets[tileID].copyPixels(tilesetBD, tempRect, tempPos );
                ++tileID;
            }
        }
    }
    public function removeAll():void {
        tileSets = new Vector.<VBitmapData>(10000, true);
    }
    public function getTile(tileID:int):VBitmapData {
        return tileSets[tileID];
    }


}
}
