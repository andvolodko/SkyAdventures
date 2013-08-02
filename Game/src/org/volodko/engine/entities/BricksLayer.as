/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 22.04.12
 * Time: 4:09
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;

import org.volodko.engine.Entity;

public class BricksLayer extends XMLLayer {

    public function BricksLayer(tileXML:XMLList, propertyXML:XMLList, sortIndex:Point) {
        super(tileXML, propertyXML, sortIndex);
    }

    override public function init():void {
        super.init();
        //
        addComponent(new BricksLayerLogic(this, tileXML, sortIndex));
        //
        initComponents();
    }
}
}
