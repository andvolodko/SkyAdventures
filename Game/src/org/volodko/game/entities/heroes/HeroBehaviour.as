/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 24.04.12
 * Time: 19:38
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.entities.heroes {
import org.volodko.engine.Component;
import org.volodko.engine.Engine;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.Keys;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.physic.Moveable;

public class HeroBehaviour extends Component {

    private var engine:Engine;
    private var graphic:Graphic;
    private var move:Moveable;
    private var keys:Keys;
    //Test
    private var moveSpeed:Number = 50;
    //


    public function HeroBehaviour(entity:Entity) {
        super(entity);
    }

    override public function init():void {
        super.init();
        //
        engine = GLB.engine;
        graphic = Graphic(getComponent(Graphic));
        move = Moveable(getComponent(Moveable));
        keys = Keys(engine.getModule(Keys));
        //
    }

    override public function update():void {
        super.update();
        //
        //Keys move
        if(keys.pressed("LEFT") || keys.pressed("A")) move.move(-moveSpeed);
        if(keys.pressed("RIGHT") || keys.pressed("D")) move.move(moveSpeed);
        if(keys.pressed("UP") || keys.pressed("W")) move.move(0,-moveSpeed);
        if(keys.pressed("DOWN") || keys.pressed("S")) move.move(0,moveSpeed);
    }
}
}
