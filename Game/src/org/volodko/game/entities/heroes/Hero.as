/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 24.04.12
 * Time: 19:08
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.entities.heroes {
import nape.phys.BodyType;

import org.volodko.engine.VSprite;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.PixelRender;
import org.volodko.engine.components.physic.Moveable;
import org.volodko.engine.components.physic.PhysicObject;
import org.volodko.engine.entities.ObjectVO;
import org.volodko.engine.entities.XMLObject;

public class Hero extends XMLObject {

    private var graphic:Graphic;
    private var sortIndex:int;

    public function Hero(object:XML, sortIndex:int) {
        this.sortIndex = sortIndex;
        super(object);
    }

    override public function init():void {
        super.init();
        //
        var displayObject:VSprite = new VSprite(HeroGr); //TODO impl. Hero2Gr
        //
        addComponent(graphic = new Graphic(this, displayObject));
        //
        graphic.x = Number(object.@x);
        graphic.y = Number(object.@y);
        //
        addComponent(new PixelRender(this, sortIndex));
        addComponent(new PhysicObject(this, BodyType.DYNAMIC  ));
        addComponent(new Moveable(this, BodyType.DYNAMIC));
        addPropeties();
        addComponent(new HeroBehaviour(this));
        //
        initComponents();
        //
    }

    private function addPropeties():void {
        for each (var property:XML in object.properties.property) {
            //trace(property.@name, property.@value);
            var params:Array = String(property.@value).split(ObjectVO.PARAMS_DELIM);
            //trace(property.@name);
            switch(String(property.@name)) {
                case ObjectVO.COM_TEST:
                    //addComponent(new Parallax(this, params[0], params[1]));
                    break;

            }
        }
    }
}
}
