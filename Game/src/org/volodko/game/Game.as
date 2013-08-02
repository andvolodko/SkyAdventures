/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 23.03.12
 * Time: 23:51
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game {

import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.utils.getTimer;

import org.volodko.engine.Console;

import org.volodko.engine.Engine;
import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.Keys;
import org.volodko.engine.Languages;
import org.volodko.engine.MsgVO;
import org.volodko.engine.PixelDisplay;
import org.volodko.engine.SOData;
import org.volodko.engine.Signals;
import org.volodko.engine.TileMap;
import org.volodko.engine.Tileset;
import org.volodko.engine.XMLData;
import org.volodko.engine.cache.Cache;
import org.volodko.engine.physic.Physic;
import org.volodko.engine.threads.Threads;
import org.volodko.engine.ui.Cursor;
import org.volodko.engine.utils.stats.StatsModule;
import org.volodko.game.helpers.GameGLB;
import org.volodko.game.scenes.GameLevel;
import org.volodko.game.scenes.Map;
import org.volodko.game.scenes.Menu;
import org.volodko.game.scenes.TestScene;

dynamic public class Game extends Engine{

    //All embedded XML data
    [Embed(source = '../../../../Resources/Settings.xml', mimeType = "application/octet-stream")] public static const Settings:Class;
    [Embed(source='../../../../Resources/CacheData.xml', mimeType="application/octet-stream")] public static const CacheData:Class;
    [Embed(source='../../../../Resources/Languages.xml', mimeType="application/octet-stream")] public static const LanguagesData:Class;
    [Embed(source='../../../../Resources/level.tmx', mimeType="application/octet-stream")] public static const Level1:Class;
    //
    private var xmlData:XMLData;
    private var cache:Cache;
    //
    public function Game() {
        //---------- Start scene
        //super(GameLevel);
        //super(TestScene);
        super(Menu);
        //super(Map);
        //super(Editor);
    }

    override public function initialize(e:Event = null):void {
        //
        var startTime:Number = getTimer();
        //
        super.initialize(e);
        //--------- Stage params ----------------
        //stage.quality = StageQuality.HIGH;
        stage.quality = StageQuality.HIGH;
        stage.align = StageAlign.TOP;
        stage.scaleMode = StageScaleMode.SHOW_ALL;
        //stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 30;
        //-------------- Add modules --------------
        addModule(new Keys());
        //
        CONFIG::debug {
            addModule(new StatsModule());
            addModule(new Console());
        }
        //
        addModule(new Threads());
        addModule(new Cursor(GameGLB.CUSTOM_CURSOR));
        addModule(xmlData = new XMLData());
        xmlData.addEmbedData("settings",Settings);
        xmlData.addEmbedData("cache",CacheData);
        xmlData.addEmbedData("languages",LanguagesData);
        xmlData.addEmbedData("level1",Level1);

        addModule(new Languages("en", "languages"));
        addModule(cache = new Cache("cache"));
        addModule(new SOData(GameGLB.sharedObjectName, GameGLB.soClear));
        addModule(new PixelDisplay(GameGLB.smoothingBD));
        addModule(new TileMap(GameGLB.mapMargin));
        addModule(new Tileset());
        addModule(new Physic(GameGLB.GRAVITY_X, GameGLB.GRAVITY_Y));
        //
        //addModule(new GameSounds());
        //addModule(new Profiler());
        //--------- Config cache ---------------
        cache.addPermClassToCache(HeroGr);
        cache.addRevertClipsClasses([HeroGr]);
        cache.addHideClipsNames(["physic", "move", "joint"]);
        cache.addCachePosNames(["physic", "move", "joint"]);
        //--------- And at end --------------------
        launchStartState();
        //
        var endTime:Number = getTimer();
        //
        CONFIG::debug {
            GLB.signals.dispatchSignal(MsgVO.LOG, "Started with no sounds: <b>"+GameGLB.noSounds+"</b>", GroupsVO.DEBUG);
            GLB.signals.dispatchSignal(MsgVO.LOG, "Engine init time: <b>"+((endTime-startTime)/1000)+"</b>", GroupsVO.DEBUG);
        }
    }

    //For intellj idea
    private function includedLibFix():void {
        HeroGr, GraphicsGr
    }
}
}
