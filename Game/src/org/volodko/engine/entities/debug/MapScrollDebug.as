/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 19.04.12
 * Time: 2:00
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities.debug {
import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.Keys;
import org.volodko.engine.TileMap;
import org.volodko.engine.entities.PixelCamera;

public class MapScrollDebug extends Entity {
    
    private var keys:Keys;
    private var tilemap:TileMap;
    //
    private var scrollSpeed:int = 50;
    private var scaleSpeed:Number = 0.05;
    private var camera:PixelCamera;
    
    public function MapScrollDebug() {
    }

    override public function init():void {
        super.init();
        //
        initComponents();
        //
        keys = Keys(GLB.engine.getModule(Keys));
        tilemap = TileMap(GLB.engine.getModule(TileMap));
        camera = PixelCamera(GLB.engine.getEntity(PixelCamera));
    }

    override public function update():void {
        super.update();
        //Zoom
        if(keys.pressed("Z")) camera.setScale(camera.scaleX-scaleSpeed, camera.scaleY-scaleSpeed);
        if(keys.pressed("X")) camera.setScale(camera.scaleX+scaleSpeed, camera.scaleY+scaleSpeed);
        //Shake
        if(keys.pressed("S")) camera.shake(10, 5, 0.1);
        //
        return;
        //Scroll
        if(keys.pressed("LEFT")) tilemap.setOffset(tilemap.getOffsetX() - scrollSpeed, tilemap.getOffsetY());
        if(keys.pressed("RIGHT")) tilemap.setOffset(tilemap.getOffsetX() + scrollSpeed, tilemap.getOffsetY());
        if(keys.pressed("UP")) tilemap.setOffset(tilemap.getOffsetX(), tilemap.getOffsetY() - scrollSpeed);
        if(keys.pressed("DOWN")) tilemap.setOffset(tilemap.getOffsetX(), tilemap.getOffsetY() + scrollSpeed);
    }
}
}
