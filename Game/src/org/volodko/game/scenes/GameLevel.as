/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 07.04.12
 * Time: 3:32
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.scenes {
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getDefinitionByName;

import org.volodko.engine.Engine;
import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.MsgVO;
import org.volodko.engine.SOData;
import org.volodko.engine.Scene;
import org.volodko.engine.TileMap;
import org.volodko.engine.Tileset;
import org.volodko.engine.XMLData;
import org.volodko.engine.cache.Cache;
import org.volodko.engine.entities.BricksLayer;
import org.volodko.engine.entities.PixelCamera;
import org.volodko.engine.entities.TileLayer;
import org.volodko.engine.entities.XMLObject;
import org.volodko.engine.entities.debug.MapScrollDebug;
import org.volodko.engine.entities.pool.ObjectPool;
import org.volodko.engine.entities.triggers.Trigger;
import org.volodko.engine.physic.Physic;
import org.volodko.engine.threads.Threads;
import org.volodko.game.entities.heroes.Hero;
import org.volodko.game.helpers.GameMsg;
import org.volodko.game.scenarios.Level1;
import org.volodko.game.helpers.LevelVO;

public class GameLevel extends Scene {

    private var engine:Engine;
    //
    private var xmlData:XMLData;
    private var soData:SOData;
    private var levelXML:XML;
    private var cache:Cache;
    private var tileset:Tileset;
    private var threads:Threads;
    private var tilemap:TileMap;
    private var physic:Physic;
    //
    private var sortIndex:int = 0;
    private var childIndex:int = 0;
    private var objectChildIndex:int = 0;
    private var otherEntIndex:int = 0;
    private var mapEntIndex:int = 0;
    //


    public function GameLevel() {
        CONFIG::debug {
            trace("level create");
            dispatch(MsgVO.LOG, "Level create", GroupsVO.DEBUG);
        }
        super(LevelLoadingGr);
    }

    override protected function initialize(e:Event = null):void {
        super.initialize(e);
        //Init vars
        engine = GLB.engine;
        xmlData = XMLData(engine.getModule(XMLData));
        soData = SOData(engine.getModule(SOData));
        cache = Cache(engine.getModule(Cache));
        tileset = Tileset(engine.getModule(Tileset));
        tilemap = TileMap(engine.getModule(TileMap));
        threads = Threads(engine.getModule(Threads));
        physic = Physic(engine.getModule(Physic));
        //
        levelXML = xmlData.getXML("level1"); //TODO level
        //
        tileset.removeAll();
        cache.removeAll();
        //Set map params
        tilemap.setParams(tilemap.getMargin(), levelXML.@width, levelXML.@height, levelXML.@tilewidth, levelXML.@tileheight);
        physic.setOffsetFunctions(tilemap.getOffsetX, tilemap.getOffsetY);
        //
        //Add tile to cache
        for each (var tilest:XML in levelXML.tileset) {
            var classStr:String = String(tilest.image.@source).replace(".png", "Gr");
            tryAddToCache(classStr);
        }
        //Add objects graphic to cache
        for each (var objectgroup:XML in levelXML.objectgroup) {
            for each (var object:XML in objectgroup.object) {
                for each (var property:XML in object.properties.property) {
                    switch (String(property.@name)) {
                        case LevelVO.PROP_GRAPHIC:
                            tryAddToCache(property.@value);
                            break;
                    }
                }
            }

        }
        //
        cache.addClassToCache(HeroGr); //TODO: Hero2Gr add if need
        //
        threads.addThread(cache.cacheOnce, 1, addEntities, "Objects cache");
    }

    private function tryAddToCache(classStr:String):void {
        var className:Object = null;
        try {
            className = Class(getDefinitionByName(classStr));
        } catch (e:Error) {
        }
        //
        if (className != null) {
            //trace(className);
            //trace(cache);
            cache.addClassToCache(Class(className));
        }
    }

    private function entitiesAdded():void {
        trace("Start level");
        graphicClip.visible = false;
        dispatch(GameMsg.LEVEL_CREATED, null, GroupsVO.GAME);
        //Log
        CONFIG::debug { dispatch(MsgVO.LOG, "GameMsg.LEVEL_CREATED", GroupsVO.DEBUG); }
    }

    private function addEntities():void {
        //
        CONFIG::debug {
            dispatch(MsgVO.LOG, "Cache end", GroupsVO.DEBUG);
        }
        //
        threads.addThread(addOtherEntitiesThread, 1, null, "Other entities");
        threads.addThread(addXMLEntitiesThread, 1, null, "XML entities");
        threads.addThread(addMapPropertiesThread, 1, null, "Map properties");
        //
        threads.onFinishAdd(entitiesAdded);
        //
    }

    private function addXMLEntitiesThread():Boolean {
        //
        //trace(childIndex,levelXML.*.length());
        if(childIndex >= levelXML.*.length()) return false;
        //
        var child:XML = levelXML.*[childIndex];
        ++childIndex;
        //
        switch (String(child.name())) {

            //------------ Tilesets ---------
            case LevelVO.CHILD_TILESET:
                var classStr:String = String(child.image.@source).replace(".png", "Gr");
                var className:Class = getClass(classStr);
                //tileset firstgid="89" name="Graphics" tilewidth="50" tileheight="50    
                if (className != null) {
                    tileset.addTileset(className, child.@firstgid, child.@tilewidth, child.@tileheight);
                }
                break;

            //------ Layers ---------------
            case LevelVO.CHILD_LAYER:
            CONFIG::debug {
                dispatch(MsgVO.LOG, "Layer: " + child.@name + " " + XMLList(child.data.tile).length() + " " + child.properties.property.length(), GroupsVO.DEBUG);
            }
                if (!(child.@visible == 0)) {
                    for each (var property:XML in child.properties.property) {
                        switch (String(property.@name)) {
                            case LevelVO.PROP_TYPE:
                                switch (String(property.@value)) {
                                    case LevelVO.LAYER_GRAPHIC:
                                        addEntity(new TileLayer(child.data.tile, child.properties.property, new Point(TileMap.getSortFromGroup(sortIndex), 0)));
                                        ++sortIndex;
                                        break;
                                    case LevelVO.LAYER_BRICKS:
                                        addEntity(new BricksLayer(child.data.tile, child.properties.property, new Point(TileMap.getSortFromGroup(sortIndex), 0)));
                                        ++sortIndex;
                                        break;
                                    case LevelVO.LAYER_PATH:
                                        //TODO
                                        break;
                                }
                                break;
                        }
                    }

                }
                break;

            //------------ Objects --------
            case LevelVO.CHILD_OBJECTGROUP:
                //trace(childIndex, objectChildIndex, child.object.*.length());
                if(objectChildIndex >= child.*.length()) {
                    objectChildIndex = 0; break;
                }
                var object:XML = child.*[objectChildIndex];
                trace(object.@name, object.@type, object.@gid, object.@x, object.@y);
                    switch(String(object.@type)) {
                        case LevelVO.TYPE_ENEMY:
                            break;
                        case LevelVO.TYPE_TRIGGER:
                                addEntityNoUpdate(new Trigger(object, sortIndex));
                            break;
                        case LevelVO.TYPE_HERO:
                                addEntity(new Hero(object, sortIndex));
                            break;
                    }
                --childIndex; //Keep in this child while
                ++sortIndex;
                ++objectChildIndex;
                break;
        }
        
        return true;//Continue thread
    }

    private function addMapPropertiesThread():Boolean {
        //trace(mapEntIndex,levelXML.properties.*.length());
        //
        if(mapEntIndex >= levelXML.properties.*.length()) return false;
        //
        var child:XML = levelXML.properties.*[mapEntIndex];
        ++mapEntIndex;
        //
        //trace(String(child.@name));
        switch (String(child.@name)) {
            //------------ Tilesets ---------
            case LevelVO.PROP_SCENARIO:
                    //trace("Scenario", child.@value);
                    var scenario:Class = LevelVO.getClass(String(child.@value));
                    //getClass(String(child.@value)); //Not work WTF
                    if(scenario) addEntity(new scenario());
                break;
        }
        //
        return true;//Continue thread
    }

    private function addOtherEntitiesThread():Boolean {
        switch(otherEntIndex) {
            case 0:
                //
                addEntity(new PixelCamera());
                break;
            case 1:
                addEntity(new ObjectPool());
                break;

            case 2:
                CONFIG::debug {
                    //Test
                    addEntity(new MapScrollDebug());
                }
                break;
            case 3:
                break;

            default:
                return false; //Stop
        }
        //
        ++otherEntIndex;
        //
        return true; //Continue
    }

    //Help functions
    private function getClass(classStr:String):Class {
        var className:Object = null;
        try {
            className = Class(getDefinitionByName(classStr));
        } catch (e:Error) {
            trace("ERROR: Class not found "+classStr);
        }
        //
        if (className != null) return Class(className);
        else return null;
    }

}
}
