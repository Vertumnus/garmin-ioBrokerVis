using Toybox.WatchUi;
using Toybox.Lang;

class SpaceView extends WatchUi.View {

    private var mTextSize;

    function initialize() {
        View.initialize();
        mTextSize = Graphics.getFontHeight(Application.getApp().GioBFont);
    }

    function getDevicePositionX(dc, size, index, offset){
        return (dc.getWidth() * Application.getApp().aPositions[size][index]["x"] / 100 + offset);
    }

    function getDevicePositionY(dc, size, index, offset){
        return (dc.getHeight() * Application.getApp().aPositions[size][index]["y"] / 100 + offset);
    }

    function createSpaceIcon(dc, dSpace){
        var oIcon = new BaseText({
            :text=>ioBrokerUtil.getIconId(dSpace["icon"], null),
            :color=>ioBrokerUtil.getColor(dSpace["color"], Graphics.COLOR_YELLOW),
            :font=>Application.getApp().GioBFont
        });
        return new WatchUi.Button({
            :locX=>dc.getWidth()/2,
            :locY=>dc.getHeight()/2 - mTextSize/2,
            :width=>mTextSize,
            :height=>mTextSize,
            :stateDefault=>oIcon,
            :stateDisabled=>Graphics.COLOR_BLACK,
            :behavior=>:onRefresh
        });
    }

    function createObject(dc, dObject as Toybox.Lang.Dictionary){
        var oIconOff, oIconOn, oIcon, sTrue = null, sFalse = null;
        if(dObject["true"] != null){
            sTrue = dObject["true"];
        }
        if(dObject["false"] != null){
            sFalse = dObject["false"];
        }
        if(dObject["get"] != null && dObject["set"] != null){
            oIconOff = new BaseText({
                :text=>ioBrokerUtil.getIconId(dObject["type"], false),
                :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            oIconOn = new BaseText({
                :text=>ioBrokerUtil.getIconId(dObject["type"], true),
                :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            return new ObjectSwitch({
                :locX=>dc.getWidth()/2,
                :locY=>dc.getHeight()/2 - mTextSize/2,
                :width=>mTextSize,
                :height=>mTextSize,
                :stateDefault=>oIconOff,
                :stateHighlighted=>oIconOn,
                :stateHighlightedOn=>oIconOn,
                :stateSelected=>oIconOn,
                :stateDisabled=>Graphics.COLOR_BLACK,
                :getIoState=>new Lang.Method(Application.getApp(), :getIoState),
                :setIoState=>new Lang.Method(Application.getApp(), :setIoState),
                :getter=>dObject["get"],
                :setter=>dObject["set"],
                :mapTrue=>sTrue,
                :mapFalse=>sFalse
            });
        }
        else if(dObject["get"] != null){
            switch(dObject["type"]){
                case "text":
                    return new ObjectText({
                        :locX=>dc.getWidth()/2,
                        :locY=>dc.getHeight()/2,
                        :font=>Graphics.FONT_TINY,
                        :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_WHITE),
                        :text=>"?",
                        :getIoState=>new Lang.Method(Application.getApp(), :getIoState),
                        :getter=>dObject["get"],
                        :unit=>dObject["unit"],
                        :precision=>dObject["precision"]
                    });
                case "state":
                    var scopes = [];
                    var color;
                    for(var i = 0; i < dObject["scopes"].size(); ++i){
                        var scope = dObject["scopes"][i];
                        if(scope["type"].equals("text")){
                            oIcon = null;
                            color = ioBrokerUtil.getColor((scope["color"] == null ? dObject["color"] : scope["color"]), Graphics.COLOR_WHITE);
                        }
                        else{
                            color = null;
                            oIcon = new BaseText({
                                :text=>ioBrokerUtil.getIconId(scope["type"], null),
                                :color=>ioBrokerUtil.getColor((scope["color"] == null ? dObject["color"] : scope["color"]), Graphics.COLOR_BLUE),
                                :font=>Application.getApp().GioBFont
                            });
                        }
                        scopes.add({ "value"=>scope["value"], "min"=>scope["min"], "max"=>scope["max"], "icon"=>oIcon, "color"=>color });
                    }
                    return new ObjectState({
                        :locX=>dc.getWidth()/2,
                        :locY=>dc.getHeight()/2,
                        :scopes=>scopes,
                        :getIoState=>new Lang.Method(Application.getApp(), :getIoState),
                        :getter=>dObject["get"],
                        :unit=>dObject["unit"],
                        :precision=>dObject["precision"]
                    });
                default:
                    oIconOff = new BaseText({
                        :text=>ioBrokerUtil.getIconId(dObject["type"], false),
                        :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_BLUE),
                        :font=>Application.getApp().GioBFont
                    });
                    oIconOn = new BaseText({
                        :text=>ioBrokerUtil.getIconId(dObject["type"], true),
                        :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_BLUE),
                        :font=>Application.getApp().GioBFont
                    });
                    return new ObjectState({
                        :locX=>dc.getWidth()/2,
                        :locY=>dc.getHeight()/2,
                        :scopes=>[{ "value"=>false, "icon"=>oIconOff },{ "value"=>true, "icon"=>oIconOn }],
                        :getIoState=>new Lang.Method(Application.getApp(), :getIoState),
                        :getter=>dObject["get"],
                        :mapTrue=>sTrue,
                        :mapFalse=>sFalse
                    });
            }
        }
        else{
            oIcon = new BaseText({
                :text=>ioBrokerUtil.getIconId(dObject["type"], true),
                :color=>ioBrokerUtil.getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            return new ObjectButton({
                :locX=>dc.getWidth()/2,
                :locY=>dc.getHeight()/2 - mTextSize/2,
                :width=>mTextSize,
                :height=>mTextSize,
                :stateDefault=>oIcon,
                :stateHighlighted=>oIcon,
                :stateSelected=>oIcon,
                :stateDisabled=>Graphics.COLOR_BLACK,
                :setIoState=>new Lang.Method(Application.getApp(), :setIoState),
                :setter=>dObject["set"],
                :command=>dObject["value"]
            });
        }
    }

    // Load your resources here
    function onLayout(dc) {
        var dSpace = Application.getApp().getCurrentSpace();
        if(dSpace == null){
            return;
        }
        
        var aObjects = dSpace["objects"];
        var aViewItems = [];
        for(var i = 0; i < aObjects.size(); ++i){
            aViewItems.add(createObject(dc, aObjects[i]));
        }
        Application.getApp().setViewItems(aViewItems);

        var aDraws = [];
        aDraws.add(createSpaceIcon(dc, dSpace));
        aDraws.addAll(aViewItems);
        setLayout(aDraws);

        for(var i = 0; i < aViewItems.size(); ++i){
            var x = getDevicePositionX(dc, aViewItems.size(), i, aViewItems[i].getOffsetX());
            var y = getDevicePositionY(dc, aViewItems.size(), i, aViewItems[i].getOffsetY());
            if(x != aViewItems[i].locX){
                WatchUi.animate(aViewItems[i], :locX, WatchUi.ANIM_TYPE_EASE_OUT, aViewItems[i].locX, x, 1, null);
            }
            if(y != aViewItems[i].locY){
                WatchUi.animate(aViewItems[i], :locY, WatchUi.ANIM_TYPE_EASE_OUT, aViewItems[i].locY, y, 1, null);
            }
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        Application.getApp().atSpace();
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.clear();
        if(Application.getApp().hasError()){
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(dc.getWidth() / 2, dc.getHeight() / 2, mTextSize * 0.75);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
