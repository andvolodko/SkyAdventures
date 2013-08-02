package org.volodko.engine {
import org.volodko.engine.interfaces.IUpdatable;

public class Module extends GameObject implements IUpdatable {
    protected var enabled:Boolean = true;
    //
    public function Module() {
    }

    public function update():void {
    }


    public function postUpdate():void {
    }

    public function enable():void {
        enabled = true;
    }

    public function disable():void {
        enabled = false;
    }
}

}