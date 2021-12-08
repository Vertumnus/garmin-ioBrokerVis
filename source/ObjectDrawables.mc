using Toybox.WatchUi;

class ObjectText extends WatchUi.Text {

    private var getterId;
    private var unitText;

    function initialize(settings){
        WatchUi.Text.initialize(settings);

        getterId = settings.get(:getter);
        unitText = settings.get(:unit);

        updateState(null);
    }

    function getOffsetX(){
        return 0;
    }

    function getOffsetY(){
        return Graphics.getFontHeight(mFont) / -2;
    }

    function updateState(value){
        Application.getApp().getIoState(getterId, method(:onIoState));
    }

    function onIoState(id, value){
        var text = value.toString();
        if(unitText != null){
            text += unitText;
        }
        setText(text);
    }

}

class ObjectBitmap extends WatchUi.Drawable {

    var stateOn;
    var stateOff;
    var currentState;

    private var getterId;
    private var mappingTrue;
    private var mappingFalse;

    function initialize(settings){
        WatchUi.Drawable.initialize(settings);

        getterId = settings.get(:getter);
        mappingTrue = settings.get(:mapTrue);
        mappingFalse = settings.get(:mapFalse);

        stateOn = settings.get(:stateOn);
        stateOff = settings.get(:stateOff);

        currentState = stateOff;

        updateState(null);
    }

    function getOffsetX(){
        return -25;
    }

    function getOffsetY(){
        return -25;
    }

    function updateState(value){
        Application.getApp().getIoState(getterId, method(:onIoState));
    }

    function onIoState(id, value){
        if(mapFrom(value)){
            currentState = stateOn;
        }
        else{
            currentState = stateOff;
        }
    }

    function mapFrom(value){
        if(mappingTrue == null && mappingFalse == null){
            return value;
        }
        return value == mappingTrue;
    }

    function draw(dc){
        currentState.setLocation(locX, locY);
        currentState.draw(dc);
    }
}

class ObjectButton extends WatchUi.Button{

    private var setterId;
    private var commandValue;
    private var mappingTrue;
    private var mappingFalse;

    function initialize(settings){
        WatchUi.Button.initialize(settings);

        setterId = settings.get(:setter);
        commandValue = settings.get(:command);
        mappingTrue = settings.get(:mapTrue);
        mappingFalse = settings.get(:mapFalse);

        updateState(null);
    }

    function execute(){
        updateState(commandValue);
    }

    function getOffsetX(){
        return -25;
    }

    function getOffsetY(){
        return -25;
    }

    function updateState(value){
        if(value != null){
            Application.getApp().setIoState(setterId, mapTo(value), null);
        }
    }

    function mapTo(value){
        if(value && mappingTrue != null){
            return mappingTrue;
        }
        if(!value && mappingFalse != null){
            return mappingFalse;
        }
        return value;
    }
}

class ObjectSwitch extends WatchUi.Selectable {

    var stateHighlightedOn;

    private var getterId;
    private var setterId;
    private var mappingTrue;
    private var mappingFalse;

    function initialize(settings) {
        WatchUi.Selectable.initialize(settings);

        stateHighlightedOn = settings.get(:stateHighlightedOn);

        getterId = settings.get(:getter);
        setterId = settings.get(:setter);
        mappingTrue = settings.get(:mapTrue);
        mappingFalse = settings.get(:mapFalse);

        updateState(null);
    }

    function getOffsetX(){
        return -25;
    }

    function getOffsetY(){
        return -25;
    }

    function updateState(value){
        if(value != null){
            Application.getApp().setIoState(setterId, mapTo(value), method(:onIoState));
        }
        else{
            Application.getApp().getIoState(getterId, method(:onIoState));
        }
    }

    function onIoState(id, value){
        if(mapFrom(value)){
            setState(:stateHighlightedOn);
        }
        else{
            setState(:stateDefault);
        }
    }

    function mapFrom(value){
        if(mappingTrue == null && mappingFalse == null){
            return value;
        }
        return value == mappingTrue;
    }

    function mapTo(value){
        if(value && mappingTrue != null){
            return mappingTrue;
        }
        if(!value && mappingFalse != null){
            return mappingFalse;
        }
        return value;
    }

    function change(previousState, currentState){
        switch(currentState){
            case :stateSelected: // User selected/tapped the Switch
                switch(previousState){
                    case :stateHighlighted: // if previous is highlighted (comes from switched off), we want to switch on
                        setState(:stateHighlightedOn);
                        updateState(true);
                        break;
                    case :stateHighlightedOn: // if previous is higlighted on (comes from switched on), we want to switch off
                        setState(:stateHighlighted);
                        updateState(false);
                        break;
                }
                break;
            case :stateDefault:
            case :stateHighlighted:
                // highlighted on (switched on) must remain unchanged
                if(previousState == :stateHighlightedOn){
                    setState(:stateHighlightedOn);
                }
                break;
        }
    }

(:debug)    function printState(state){
        switch(state){
            case :stateDefault:
                return("Default");
            case :stateHighlighted:
                return("Highlight");
            case :stateHighlightedOn:
                return("HighlightOn");
            case :stateSelected:
                return("Selected");
        }
    }
}