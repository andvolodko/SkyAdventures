/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 22.04.12
 * Time: 4:19
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;
import flash.geom.Rectangle;

import org.volodko.engine.Component;
import org.volodko.engine.Engine;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.PixelDisplay;
import org.volodko.engine.TileMap;
import org.volodko.engine.Tileset;
import org.volodko.engine.components.Graphic;

public class XMLLayerLogic extends Component {
    protected var engine:Engine;

    protected var tileXML:XMLList;

    protected var tiles:Vector.<Vector.<int>>;

    protected var tilemap:TileMap;

    protected var sortIndex:Point;

    protected var tileID:int = 0;

    protected var cellRect:Rectangle;
    protected var cellWidth:int = 0;
    protected var cellHeight:int = 0;

    public function XMLLayerLogic(entity:Entity, tileXML:XMLList, sortIndex:Point) {
        this.tileXML = tileXML;
        this.sortIndex = sortIndex;
        super(entity);
    }

    override public function init():void {
        super.init();
        //
        engine = GLB.engine;
        tilemap = TileMap(engine.getModule(TileMap));
        //
        tiles = new Vector.<Vector.<int>>();
        //
        //
        cellRect = tilemap.getCellRect();
        cellWidth = tilemap.getCellWidth();
        cellHeight = tilemap.getCellHeight();
        //
        var xx:int = 0;
        var yy:int = 0;
        tiles.push(new Vector.<int>());
        for each (var tile:XML in tileXML) {
            tiles[yy].push(int(tile.@gid));
            ++xx;
            if (xx >= tilemap.getWidth()) {
                xx = 0;
                tiles.push(new Vector.<int>());
                ++yy;
            }
        }
        //
    }
}
}
