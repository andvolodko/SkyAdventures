/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 19.04.12
 * Time: 0:03
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import caurina.transitions.Tweener;

import flash.geom.Matrix;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import org.volodko.engine.utils.LoDMath;


public class TileMap extends Module {
    //
    static private var groups:Dictionary;
    static private var groupsAdd:int = 1000;
    static private var groupTemp:String = "";
    //
    private var mapMargin:int = 0;
    private var mapWidth:int = 0;
    private var mapHeight:int = 0;
    private var cellWidth:int = 0;
    private var cellHeight:int = 0;
    private var horCells:int = 0;
    private var verCells:int = 0;
    //
    private var mapBD:VBitmapData;
    private var pixelDisplay:PixelDisplay;
    //
    private var drawPos:Point = new Point();
    //
    //Render
    private var renderQueue:Vector.<Object>;
    private var renderQueuePost:Vector.<Object>;
    //
    private var offsetX:int = 0;
    private var offsetY:int = 0;
    private var cellRect:Rectangle = new Rectangle();
    private var tempRect:Rectangle = new Rectangle();
    private var matrix:Matrix = new Matrix();
    private var aspectRatio:Number;
    //
    private var mapPixelWidth:int = 0;
    private var mapPixelHeight:int = 0;
    private var maxScrollX:int = 0;
    private var maxScrollY:int = 0;
    //
    public function TileMap(mapMargin:int = 0) {
        this.mapMargin = mapMargin;
        super();
        init();
    }

    private function init():void {
        pixelDisplay = PixelDisplay(GLB.engine.getModule(PixelDisplay));
        aspectRatio = GLB.width/GLB.height;
        mapBD = new VBitmapData(GLB.width + mapMargin*2*aspectRatio, GLB.height + mapMargin*2, true);
        //
        //
        renderQueue = new Vector.<Object>();
        renderQueuePost = new Vector.<Object>();
        //
    }

    override public function update():void {
        super.update();
        //
        //updatePosition();
        //postUpdate();
        //CONFIG::debug { dispatch(MsgVO.LOG_TEMP, "Cells rect: "+cellRect, GroupsVO.DEBUG); }
        CONFIG::debug { dispatch(MsgVO.LOG_TEMP, "Offsets: "+getOffsetX()+" ; "+getOffsetY(), GroupsVO.DEBUG); }
    }
    
    public function setParams(mapMargin:int, mapWidth:int, mapHeight:int, cellWidth:int, cellHeight:int):void {
        this.mapMargin = mapMargin;
        this.mapWidth = mapWidth;
        this.mapHeight = mapHeight;
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;
        //
        horCells = Math.ceil(mapBD.width/cellWidth);
        verCells = Math.ceil(mapBD.height/cellHeight);
        //
        mapPixelWidth = mapWidth * cellWidth;
        mapPixelHeight = mapHeight * cellHeight;
        maxScrollX = mapPixelWidth - mapBD.width;
        maxScrollY = mapPixelHeight - mapBD.height;
        //
        updatePosition();
    }


    public function getMargin():int { return mapMargin; }
    public function getWidth():int {return mapWidth; }
    public function getHeight():int {return mapHeight; }
    public function getCellWidth():int {return cellWidth; }
    public function getCellHeight():int {return cellHeight; }
    public function getCellRect():Rectangle { return cellRect; }
    public function getMapBD():VBitmapData { return mapBD;}
    public function getAspectRation():Number { return aspectRatio; }

    public function getCustomCellRect(customOffsetX:int,  customOffsetY:int):Rectangle {
        //
        tempRect.x = int(customOffsetX/cellWidth);
        tempRect.y = int(customOffsetY/cellHeight);
        tempRect.width = tempRect.x + horCells;
        tempRect.height = tempRect.y + verCells;
        //Check
        if(tempRect.x <= 0) tempRect.x = 0;
        if(tempRect.y <= 0) tempRect.y = 0;
        if(tempRect.x >= mapWidth) tempRect.x = mapWidth-1;
        if(tempRect.y >= mapHeight) tempRect.y = mapHeight-1;
        if(tempRect.width <= 0) tempRect.width = 0;
        if(tempRect.height <= 0) tempRect.height = 0;
        if(tempRect.width >= mapWidth) tempRect.width = mapWidth-1;
        if(tempRect.height >= mapHeight) tempRect.height = mapHeight-1;
        //
        return tempRect;
    }
    
    private function updatePosition():void {
        if(cellWidth <=0 || cellHeight <= 0) return;
        //
        cellRect.x = int(offsetX/cellWidth);
        cellRect.y = int(offsetY/cellHeight);
        cellRect.width = cellRect.x + horCells; 
        cellRect.height = cellRect.y + verCells;
        //Check
        if(cellRect.x <= 0) cellRect.x = 0;
        if(cellRect.y <= 0) cellRect.y = 0;
        if(cellRect.x >= mapWidth) cellRect.x = mapWidth-1;
        if(cellRect.y >= mapHeight) cellRect.y = mapHeight-1;
        if(cellRect.width <= 0) cellRect.width = 0;
        if(cellRect.height <= 0) cellRect.height = 0;
        if(cellRect.width >= mapWidth) cellRect.width = mapWidth-1;
        if(cellRect.height >= mapHeight) cellRect.height = mapHeight-1;
    }

    override public function postUpdate():void {
        if (!enabled) return;
        //
        mapBD.fillRect(mapBD.rect, 0);
        //
        CONFIG::debug {
            dispatch(MsgVO.LOG_TEMP, "RenderQueue length: <b>" + renderQueue.length+"</b>", GroupsVO.DEBUG);
            var st:Number = getTimer();
        }
        //
        //renderQueue.sort(mapSortFunctionX); //Very weak place
        //
        mapBD.lock();
        //
        while (renderQueue.length > 0) {
            var renderItem:Object = renderQueue.shift();
            if (renderItem is RenderQueueData)
                renderNow(renderItem.bd, renderItem.pos, renderItem.rotation, renderItem.rotMargin);
            else if (renderItem is DrawQueueData) {
                var drawData:DrawQueueData = DrawQueueData(renderItem);
                switch (drawData.type) {
                    case DrawQueueData.TYPE_LINE:
                        if (drawData.antiAliasing)
                            mapBD.aaLine(drawData.getLineData().x1, drawData.getLineData().y1, drawData.getLineData().x2, drawData.getLineData().y2, drawData.getLineData().color);
                        else mapBD.line(drawData.getLineData().x1, drawData.getLineData().y1, drawData.getLineData().x2, drawData.getLineData().y2, drawData.getLineData().color);
                        break;
                }
            }
        }
        while (renderQueuePost.length > 0) {
            renderItem = renderQueuePost.shift();
            renderNow(renderItem.bd, renderItem.pos, renderItem.rotation, renderItem.rotMargin);
        }
        //
        mapBD.unlock();
        //
        //pixelDisplay.clearBD();
        //pixelDisplay.renderNow(mapBD, drawPos);
        //pixelDisplay.drawNow(mapBD);
        //
        CONFIG::debug {
            var et:Number = getTimer();
            dispatch(MsgVO.LOG_TEMP, "Render time: <b>" + ((et - st) / 1000) + "</b>", GroupsVO.DEBUG);
        }
    }

    private function mapSortFunctionX(item1:RenderQueueData, item2:RenderQueueData):int {
        var xRes:Boolean = item1.x < item2.x;
        if (xRes) {
            return -1;
        }
        if (!xRes) {
            return 1;
        }
        return 0;
    }

    //---------------- render interface -------------
    public function renderNow(bdToCopy:VBitmapData, pos:Point, rotation:Number = 0, rotMargin:Point = null):void {
        //Add offset
        pos.x -= offsetX;
        pos.y -= offsetY;
        //
        if (rotation != 0) {
            //Draw
            matrix.identity();
            if (rotMargin) matrix.translate(rotMargin.x, rotMargin.y);
            matrix.rotate(LoDMath.degreesToRadians(rotation));
            if (rotMargin) matrix.translate(-rotMargin.x, -rotMargin.y);
            matrix.translate(pos.x, pos.y);
            mapBD.draw(bdToCopy, matrix, null, null, null, true);
        } else {
            //Copy pixels
            mapBD.copyPixels(bdToCopy, bdToCopy.rect, pos, null, null, true);
        }
    }


    public function renderSorted(bdToCopy:VBitmapData, pos:Point, sortPos:Point, rotation:Number = 0, rotMargin:Point = null):void {
        renderQueue.push(new RenderQueueData(bdToCopy, pos, sortPos, rotation, rotMargin));
    }

    public function renderPost(bdToCopy:VBitmapData, pos:Point, sortPos:Point, rotation:Number = 0, rotMargin:Point = null):void {
        renderQueuePost.push(new RenderQueueData(bdToCopy, pos, sortPos, rotation, rotMargin));
    }

    public function drawLineSorted(x1:int, y1:int, x2:int, y2:int, color:uint, sort:int):void {
        var drawData:DrawQueueData = new DrawQueueData(sort, DrawQueueData.TYPE_LINE);
        drawData.setLineData(x1 + offsetX, y1 + offsetY, x2 + offsetX, y2 + offsetY, color); //With offset
        renderQueue.push(drawData);
    }

    public function debugRender(posX:Number, posY:Number, color:uint = 0xAAffff00):void {
        var bd:VBitmapData = new VBitmapData(5, 5, true, color);
        renderPost(bd, new Point(posX, posY), new Point());
    }

    //---------------- render end -------------



    public function setOffset(offX:int, offY:int):void {
        //trace(offX, offY, mapPixelWidth, mapPixelHeight);
        //Tweener.addTween(this, {offsetX:offX, offsetY:offY, time:0.1, overwrite:true, transition:"easeInSine"});
        offsetX = offX;
        offsetY = offY;
        //
        checkOffset();
    }

    private function checkOffset():void {
        //Check
        if(offsetX < 0) offsetX = 0;
        if(offsetY < 0) offsetY = 0;
        if(offsetX > maxScrollX) offsetX = maxScrollX;
        if(offsetY > maxScrollY) offsetY = maxScrollY;
        updatePosition();
    }

    public function getOffsetX():int { return offsetX; }
    public function getOffsetY():int { return offsetY; }
    public function set offsetXSetter(value:Number):void {
        offsetX = value;
        checkOffset();
    }
    public function set offsetYSetter(value:Number):void {
        offsetY = value;
        checkOffset();
    }
    public function get offsetXSetter():Number {
        return offsetX;
    }
    public function get offsetYSetter():Number {
        return offsetY;
    }
    
    //------------------------ Static -----------------------
    static public function getSortFromGroup(groupNum:int):int {
        if (!groups) resetGroups();
        groupTemp = "group" + groupNum;
        if (!groups[groupTemp]) groups[groupTemp] = 0;
        groups[groupTemp] = groups[groupTemp] + 1;
        return groupsAdd * groupNum + groups[groupTemp];
    }

    static public function resetGroups():void {
        groups = new Dictionary(false);
    }

}
}




import flash.geom.Point;

import org.volodko.engine.VBitmapData;

class RenderQueueData {
    //
    public var y:Number;
    public var x:Number;
    public var pos:Point;
    public var sortPos:Point;
    public var bd:VBitmapData;
    public var rotation:Number;
    public var rotMargin:Point;
    //
    public function RenderQueueData(bd:VBitmapData, pos:Point, sortPos:Point, rotation:Number, rotMargin:Point = null) {
        this.y = sortPos.y;
        this.x = sortPos.x;
        this.bd = bd;
        this.pos = pos;
        this.sortPos = sortPos;
        this.rotation = rotation;
        this.rotMargin = rotMargin;
    }
}

class DrawQueueData {

    static public const TYPE_LINE:String = "line";
    //
    public var type:String;
    public var y:int;
    //
    public var antiAliasing:Boolean = false;
    //
    private var lineData:Object;
    //

    public function DrawQueueData(sort:int, type:String) {
        this.type = type;
        this.y = sort;
    }

    public function setLineData(x1:int, y1:int, x2:int, y2:int, color:uint):void {
        lineData = {
            x1:x1,
            y1:y1,
            x2:x2,
            y2:y2,
            color:color
        };
    }

    public function getLineData():Object {
        return lineData;
    }
}
