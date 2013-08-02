/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 25.04.12
 * Time: 0:06
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.scenarios {
import org.volodko.engine.Engine;
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.entities.PixelCamera;
import org.volodko.engine.utils.TransitionsVO;
import org.volodko.game.entities.heroes.Hero;
import org.volodko.game.helpers.GameMsg;

public class Level1 extends Entity {
    
    private var engine:Engine;
    private var hero:Hero;
    private var camera:PixelCamera;
    private var heroGraphic:Graphic;
    
    public function Level1() {
        super();
    }

    override public function init():void {
        super.init();
        //
        initComponents();
        //
        trace("Level1 scenario started");
        register(signalListener, GroupsVO.GAME);
        //
        engine = GLB.engine;
        hero = Hero(engine.getEntity(Hero));
        heroGraphic = Graphic(hero.getComponent(Graphic));
        camera = PixelCamera(engine.getEntity(PixelCamera));
        //
    }

    private function startScenario():void {
        //
        camera.fade();
        camera.fadeEnd(1);
        camera.zoom(0);
        camera.zoom(1, 1, 1, null, TransitionsVO.EASE_OUT_SINE);
        camera.setGraphicFocus(heroGraphic);
        camera.setGraphicFollow(heroGraphic);
    }
    
    private function signalListener(msg:String, data:Object):void {
        switch(msg) {
            case GameMsg.LEVEL_CREATED:
                    startScenario();
                break;
        }
    }

}

}
