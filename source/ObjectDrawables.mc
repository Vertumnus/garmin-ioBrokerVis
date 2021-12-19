using Toybox.WatchUi;

class BaseText extends WatchUi.Text {

    function initialize(settings){
        WatchUi.Text.initialize(settings);
    }

    function getFont(){
        return mFont;
    }
}

class ObjectText extends BaseText {

    protected var getterId;
    protected var unitText;
    protected var decimalPrecision;

    function initialize(settings){
        BaseText.initialize(settings);

        getterId = settings.get(:getter);
        unitText = settings.get(:unit);
        decimalPrecision = settings.get(:precision);
        decimalPrecision = (decimalPrecision == null) ? 0 : decimalPrecision.toNumber();

        updateState(null);
    }

    function getOffsetX(){
        return 0;
    }

    function getOffsetY(){
        return Graphics.getFontHeight(mFont) / -2;
    }

    function buildText(value){
        var text = "";
        switch(value){
            case instanceof String:
                text = value;
                break;
            default:
                var pattern = "%d";
                if(decimalPrecision >= 0){
                    pattern = Lang.format("%1.$1$f", [decimalPrecision.format("%d")]);
                }
                text = value.format(pattern);
                break;
        }
        if(unitText != null){
            text += unitText;
        }
        return text;
    }

    function updateState(value){
        Application.getApp().getIoState(getterId, method(:onIoState));
    }

    function onIoState(id, value){
        setText(buildText(value));
    }
}

class ObjectState extends ObjectText {

    private var allScopes;
    private var currentState;
    private var scopeText;

    private var mappingTrue;
    private var mappingFalse;

    function initialize(settings){
        ObjectText.initialize(settings);

        mappingTrue = settings.get(:mapTrue);
        mappingFalse = settings.get(:mapFalse);

        allScopes = settings.get(:scopes);
        currentState = null;

        updateState(null);
    }

    function getOffsetY(){
        if(currentState == null){
            return 0;
        }
        else{
            return Graphics.getFontHeight(currentState.getFont()) / -2;
        }
    }

    function updateState(value){
        Application.getApp().getIoState(getterId, method(:onIoState));
    }

    function findScope(value){
        var scope = null;
        for(var i = 0; i < allScopes.size(); ++i){
            if(allScopes[i]["value"] != null){
                if(value.toString().equals(allScopes[i]["value"].toString())){
                    scope = allScopes[i];
                    break;
                }
            }
            else if(allScopes[i]["min"] == null){
                if(value.toNumber() <= allScopes[i]["max"].toNumber()){
                    scope = allScopes[i];
                    break;
                }
            }
            else if(allScopes[i]["max"] == null){
                if(value.toNumber() >= allScopes[i]["min"].toNumber()){
                    scope = allScopes[i];
                    break;
                }
            }
            else{
                if(value.toNumber() >= allScopes[i]["min"].toNumber() && value.toNumber() <= allScopes[i]["max"].toNumber()){
                    scope = allScopes[i];
                    break;
                }
            }
        }
        if(scope == null){
            return null;
        }
        if(scope["icon"] != null){
            return scope["icon"];
        }
        if(scopeText == null){
            scopeText = new BaseText({
                :justification=>Graphics.TEXT_JUSTIFY_CENTER,
                :font=>Graphics.FONT_TINY,
                :text=>"?"
            });
        }
        scopeText.setText(buildText(value));
        scopeText.setColor(scope["color"]);
        return scopeText;
    }

    function onIoState(id, value){
        currentState = findScope(mapFrom(value));
    }

    function mapFrom(value){
        if(mappingTrue == null && mappingFalse == null){
            return value;
        }
        return value == mappingTrue;
    }

    function draw(dc){
        if(currentState != null){
            currentState.setLocation(locX + getOffsetX(), locY + getOffsetY());
            currentState.draw(dc);
        }
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
        return width / -2;
    }

    function getOffsetY(){
        return height / -2;
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
        return width / -2;
    }

    function getOffsetY(){
        return height / -2;
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
}