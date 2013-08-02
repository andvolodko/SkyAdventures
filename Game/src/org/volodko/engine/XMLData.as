/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 10.04.12
 * Time: 11:07
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class XMLData extends Module {

    private var xmlDictionary:Dictionary = new Dictionary();

    public function XMLData() {
    }
    public function addEmbedData(id:String, dataClass:Class):void {
        if(xmlDictionary[id]) trace("ERROR: Have data with this id");
        else {
            var file:ByteArray = new dataClass();
            var str:String = file.readUTFBytes( file.length );
            xmlDictionary[id] = new XML( str );
        }
    }
    public function addExternalData(id:String, url:String):void {
        if(xmlDictionary[id]) trace("ERROR: Have data with this id");
        else {
            //TODO: Load external XMl
            /*
            var urlRequest:URLRequest = new URLRequest(Hlp.settingsDebugUrl);
            var urlLoader:URLLoader = new URLLoader();
            //urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
            urlLoader.addEventListener(Event.COMPLETE, function(evt:Event):void {
                var xml:XML;
                settingsXML=new XML(evt.target.data);
            });
            urlLoader.load(urlRequest);

            xmlDictionary[id] = new XML( str );  */
        }
    }

    public function getXML(id:String):XML {
        return XML(xmlDictionary[id]);
    }

    public function get(id:String, value:String):String {
        return xmlDictionary[id][value];
    }

    public function getAsNumber(id:String, value:String):Number {
        return Number(get(id, value));
    }
}
}
