/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 10.04.12
 * Time: 11:15
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
public class Languages extends Module {

    private var langID:String;
    private var xmlData:XMLData;
    private var dataID:String;
    private var langXML:XML;

    public function Languages(lang:String, dataID:String) {
        langID = lang;
        this.dataID = dataID;
        init();
    }

    private function init():void {
        xmlData = XMLData(GLB.engine.getModule(XMLData));
        langXML = xmlData.getXML(dataID);
    }

    public function setLanguage(lang:String):void {
        langID = lang;
        //TODO: Dispatch to repaint all
    }

    public function get(sname:String):String {
        //trace("lng: ", langXML[langID][sname].@name);
        return langXML[langID][sname].@name;
    }

    public function getReplaced(id:String, params:Array): String
    {
        var tmpString:String = get(id);
        for (var i:int = 0; i < params.length; ++i)
        {
            tmpString = tmpString.replace("$" + (i + 1), params[i]);
        }
        return tmpString;
    }
}
}
