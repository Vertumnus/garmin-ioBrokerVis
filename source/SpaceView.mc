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

    function getIconId(sType, bOn){
        switch(sType){
            case "bathroom":
                return "\"";
            case "bedroom":
                return "_";
            case "books":
                return "\\";
            case "build":
                return "=";
            case "bulb":
                if(bOn){
                    return "B";
                }
                else{
                    return "b";
                }
            case "check":
                if(bOn){
                    return "C";
                }
                else{
                    return "c";
                }
            case "childroom":
                return "°";
            case "deck":
                return "~";
            case "dining":
                return "|";
            case "favorite":
                return "+";
            case "flash":
                if(bOn){
                    return "F";
                }
                else{
                    return "f";
                }
            case "garage":
                return "4";
            case "home":
                return "^";
            case "kitchen":
                return "&";
            case "lamp":
                return ";";
            case "living":
                return "-";
            case "lock":
                if(bOn){
                    return "L";
                }
                else{
                    return "l";
                }
            case "mic":
                if(bOn){
                    return "M";
                }
                else{
                    return "m";
                }
            case "power":
                if(bOn){
                    return "P";
                }
                else{
                    return "p";
                }
            case "speaker":
                return "0";
            case "stairs":
                return "%";
            case "star":
                return "*";
            case "thermo":
                return "!";
            case "toggle":
                if(bOn){
                    return "R";
                }
                else{
                    return "r";
                }
            case "torch":
                return ":";
            case "tv":
                return "#";
            case "vol-":
                return "v";
            case "vol+":
                return "V";
            case "wc":
                return ".";
            case "work":
                return "$";
            case "yard":
                return "?";
            default:
                throw new Lang.InvalidValueException("Unknown object type: " + sType);
        }
    }

    function getColor(sColor, defaultColor){
        if(sColor == null){
            return defaultColor;
        }
        if(sColor.find("#") == 0){
            return sColor.substring(1, sColor.length()).toNumberWithBase(16);
        }
        return sColor.toNumberWithBase(0);
    }

    function createSpaceIcon(dc, dSpace){
        var oIcon = new WatchUi.Text({
            :text=>getIconId(dSpace["icon"], null),
            :color=>getColor(dSpace["color"], Graphics.COLOR_YELLOW),
            :font=>Application.getApp().GioBFont,
            :justification=>Graphics.TEXT_JUSTIFY_CENTER
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

    function createObject(dc, dObject){
        var oIconOff, oIconOn, oIcon, sTrue = null, sFalse = null;
        if(dObject["true"] != null){
            sTrue = dObject["true"];
        }
        if(dObject["false"] != null){
            sFalse = dObject["false"];
        }
        if(dObject["get"] != null && dObject["set"] != null){
            oIconOff = new WatchUi.Text({
                :text=>getIconId(dObject["type"], false),
                :color=>getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            oIconOn = new WatchUi.Text({
                :text=>getIconId(dObject["type"], true),
                :color=>getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            return new ObjectSwitch({
                :locX=>dc.getWidth()/2 - mTextSize/2,
                :locY=>dc.getHeight()/2 - mTextSize/2,
                :width=>mTextSize,
                :height=>mTextSize,
                :stateDefault=>oIconOff,
                :stateHighlighted=>oIconOn,
                :stateHighlightedOn=>oIconOn,
                :stateSelected=>oIconOn,
                :stateDisabled=>Graphics.COLOR_BLACK,
                :getter=>dObject["get"],
                :setter=>dObject["set"],
                :mapTrue=>sTrue,
                :mapFalse=>sFalse
            });
        }
        else if(dObject["get"] != null){
            if(dObject["type"].equals("text")){
                return new ObjectText({
                    :locX=>dc.getWidth()/2,
                    :locY=>dc.getHeight()/2,
                    :justification=>Graphics.TEXT_JUSTIFY_CENTER,
                    :font=>Graphics.FONT_TINY,
                    :text=>"?",
                    :getter=>dObject["get"],
                    :unit=>dObject["unit"]
                });
            }
            else{
                oIconOff = new WatchUi.Text({
                    :text=>getIconId(dObject["type"], false),
                    :color=>getColor(dObject["color"], Graphics.COLOR_BLUE),
                    :font=>Application.getApp().GioBFont
                });
                oIconOn = new WatchUi.Text({
                    :text=>getIconId(dObject["type"], true),
                    :color=>getColor(dObject["color"], Graphics.COLOR_BLUE),
                    :font=>Application.getApp().GioBFont
                });
                return new ObjectBitmap({
                    :locX=>dc.getWidth()/2 - mTextSize/2,
                    :locY=>dc.getHeight()/2 - mTextSize/2,
                    :width=>mTextSize,
                    :height=>mTextSize,
                    :stateOff=>oIconOff,
                    :stateOn=>oIconOn,
                    :getter=>dObject["get"],
                    :mapTrue=>sTrue,
                    :mapFalse=>sFalse
                });
            }
        }
        else{
            oIcon = new WatchUi.Text({
                :text=>getIconId(dObject["type"], true),
                :color=>getColor(dObject["color"], Graphics.COLOR_BLUE),
                :font=>Application.getApp().GioBFont
            });
            return new ObjectButton({
                :locX=>dc.getWidth()/2 - mTextSize/2,
                :locY=>dc.getHeight()/2 - mTextSize/2,
                :width=>mTextSize,
                :height=>mTextSize,
                :stateDefault=>oIcon,
                :stateHighlighted=>oIcon,
                :stateSelected=>oIcon,
                :stateDisabled=>Graphics.COLOR_BLACK,
                :setter=>dObject["set"],
                :mapTrue=>sTrue,
                :mapFalse=>sFalse
            });
        }
    }

    // Load your resources here
    function onLayout(dc) {
        var dSpace = Application.getApp().getCurrentSpace();
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
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
