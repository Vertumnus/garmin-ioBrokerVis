using Toybox.WatchUi;
using Toybox.Lang;

class SpaceView extends WatchUi.View {

    private var aPositions;

    function initialize() {
        View.initialize();
        aPositions = WatchUi.loadResource(Rez.JsonData.DevicePositions);
    }

    function getDevicePositionX(dc, size, index, offset){
        return (dc.getWidth() * aPositions[size][index]["x"] / 100 + offset);
    }

    function getDevicePositionY(dc, size, index, offset){
        return (dc.getHeight() * aPositions[size][index]["y"] / 100 + offset);
    }

    function getIconId(sType, bOn){
        switch(sType){
            case "bathroom":
                return Rez.Drawables.BathroomIcon;
            case "bedroom":
                return Rez.Drawables.BedroomIcon;
            case "bulb":
                if(bOn){
                    return Rez.Drawables.BulbOn;
                }
                else{
                    return Rez.Drawables.BulbOff;
                }
            case "childroom":
                return Rez.Drawables.ChildroomIcon;
            case "deck":
                return Rez.Drawables.DeckIcon;
            case "dining":
                return Rez.Drawables.DiningIcon;
            case "exec":
                return Rez.Drawables.Execute;
            case "favorite":
                return Rez.Drawables.FavoriteIcon;
            case "garage":
                return Rez.Drawables.GarageIcon;
            case "home":
                return Rez.Drawables.HomeIcon;
            case "kitchen":
                return Rez.Drawables.KitchenIcon;
            case "living":
                return Rez.Drawables.LivingIcon;
            case "lock":
                if(bOn){
                    return Rez.Drawables.Locked;
                }
                else{
                    return Rez.Drawables.Unlocked;
                }
            case "mic":
                if(bOn){
                    return Rez.Drawables.MicOn;
                }
                else{
                    return Rez.Drawables.MicOff;
                }
            case "toggle":
                if(bOn){
                    return Rez.Drawables.On;
                }
                else{
                    return Rez.Drawables.Off;
                }
            case "power":
                if(bOn){
                    return Rez.Drawables.PowerOn;
                }
                else{
                    return Rez.Drawables.PowerOff;
                }
            case "speaker":
                return Rez.Drawables.SpeakerIcon;
            case "stairs":
                return Rez.Drawables.StairsIcon;
            case "tv":
                return Rez.Drawables.TVIcon;
            case "vol-":
                return Rez.Drawables.VolumeDown;
            case "vol+":
                return Rez.Drawables.VolumeUp;
            case "wc":
                return Rez.Drawables.WCIcon;
            case "window":
                if(bOn){
                    return Rez.Drawables.WindowOpen;
                }
                else{
                    return Rez.Drawables.WindowClose;
                }
            case "work":
                return Rez.Drawables.WorkIcon;
            case "yard":
                return Rez.Drawables.YardIcon;
            default:
                throw new Lang.InvalidValueException("Unknown object type: " + sType);
        }
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
            oIconOff = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(dObject["type"], false))});
            oIconOn = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(dObject["type"], true))});
            return new ObjectSwitch({
                :locX=>dc.getWidth()/2 - oIconOff.width/2,
                :locY=>dc.getHeight()/2 - oIconOff.height/2,
                :width=>oIconOff.width,
                :height=>oIconOff.height,
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
                oIconOff = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(dObject["type"], false))});
                oIconOn = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(dObject["type"], true))});
                return new ObjectBitmap({
                    :locX=>dc.getWidth()/2 - oIconOff.width/2,
                    :locY=>dc.getHeight()/2 - oIconOff.height/2,
                    :width=>oIconOff.width,
                    :height=>oIconOff.height,
                    :stateOff=>oIconOff,
                    :stateOn=>oIconOn,
                    :getter=>dObject["get"],
                    :mapTrue=>sTrue,
                    :mapFalse=>sFalse
                });
            }
        }
        else{
            oIcon = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(dObject["type"], null))});
            return new ObjectButton({
                :locX=>dc.getWidth()/2 - oIcon.width/2,
                :locY=>dc.getHeight()/2 - oIcon.height/2,
                :width=>oIcon.width,
                :height=>oIcon.height,
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

    function createSpaceIcon(dc, sType){
        var oIcon = new WatchUi.Bitmap({:bitmap=>WatchUi.loadResource(getIconId(sType, null))});
        return new WatchUi.Button({
            :locX=>dc.getWidth()/2 - oIcon.width/2,
            :locY=>dc.getHeight()/2 - oIcon.height/2,
            :width=>oIcon.width,
            :height=>oIcon.height,
            :stateDefault=>oIcon,
            :stateHighlighted=>oIcon,
            :stateSelected=>oIcon,
            :stateDisabled=>Graphics.COLOR_BLACK,
            :behavior=>:onRefresh
        });
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
        aDraws.add(createSpaceIcon(dc, dSpace["icon"]));
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
