/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 17.04.12
 * Time: 17:59
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;

import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.Parallax;

public class TileLayer extends XMLLayer {

    private var added:Boolean = false;

    public function TileLayer(tileXML:XMLList, propertyXML:XMLList, sortIndex:Point) {
        super(tileXML, propertyXML, sortIndex);
    }

    override public function init():void {
        super.init();
        //
        addProperties();
        //
        initComponents();
    }

    private function addProperties():void {
        for each (var property:XML in propertyXML) {
            //trace(property.@name, property.@value);
            var params:Array = String(property.@value).split(TileVO.PARAMS_DELIM);
            //trace(property.@name);
            switch(String(property.@name)) {
                case TileVO.COM_PARALLAX:
                    addComponent(new ParallaxTileLayerLogic(this, tileXML, sortIndex, params[0], params[1]));
                        added = true;
                    break;
                case TileVO.COM_SCROLL:
                    addComponent(new ScrollTileLayerLogic(this, tileXML, sortIndex, params[0], params[1]));
                        added = true;
                    break;
                case TileVO.COM_TYPE:
                        //Nothing
                    if(!added) addComponent(new TileLayerLogic(this, tileXML, sortIndex));
                    break;
                default:
                    

            }
        }

    }
}
}
