/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 22.04.12
 * Time: 4:12
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import flash.geom.Point;

import org.volodko.engine.Entity;

public class XMLLayer extends Entity {
    protected var tileXML:XMLList;

    protected var propertyXML:XMLList;

    protected var sortIndex:Point;

    public function XMLLayer(tileXML:XMLList, propertyXML:XMLList, sortIndex:Point) {
        this.tileXML = tileXML;
        this.propertyXML = propertyXML;
        this.sortIndex = sortIndex;
        super();
    }
}
}
