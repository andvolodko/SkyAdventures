/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 29.04.12
 * Time: 2:43
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities.triggers {
import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.entities.PixelCamera;

public class ShakeTrigger extends Component {
    
    private var camera:PixelCamera;
    private var type:String;
    
    public function ShakeTrigger(entity:Entity, type:String) {
        this.type = type;
        super(entity);
    }

    override public function init():void {
        super.init();
        //
        trace("Shake trigger created !");
        //
        camera = PixelCamera(GLB.engine.getEntity(PixelCamera));
    }
    
    private function onTrigger():void {
        switch(type) {
            case TriggerVO.SHAKE_TYPE_SMALL:
                camera.shake(10, 5, 0.1);
                break;
            case TriggerVO.SHAKE_TYPE_BIG:
                camera.shake(30, 10, 1);
                break;
        }

    }
}
}
