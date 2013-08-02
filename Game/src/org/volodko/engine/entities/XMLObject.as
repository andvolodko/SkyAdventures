/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 24.04.12
 * Time: 19:07
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import org.volodko.engine.Entity;

public class XMLObject extends Entity {

    protected var object:XML;

    public function XMLObject(object:XML) {
        this.object = object;
        super();
    }
}
}
