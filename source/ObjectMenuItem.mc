using Toybox.WatchUi;

class ObjectMenuItemFactory {

    private var mValue;

    function initialize() {
        return;
    }

    function createMenuItem(identifier, asState, context) {
        mValue = null;
        var lLabel = context[:object]["name"] != null ? context[:object]["name"] : "";
        if(context[:object]["get"] != null){
            context[:getIoState].invoke(context[:object]["get"], method(:onIoState)); // if value is present, invokes immediately callback
        }

        if(context[:object]["get"] != null && context[:object]["set"] != null) { // is it a toggle?
            return new ObjectToggleMenuItem(lLabel, identifier, mValue, {   :setIoState=>context[:setIoState], 
                                                                            :setter=>context[:object]["set"],
                                                                            :mapTrue=>context[:object]["true"],
                                                                            :mapFalse=>context[:object]["false"] });
        }
        else if(context[:object]["get"] != null) {
            switch(context[:object]["type"]) {
                case "text":
                    return new ObjectTextMenuItem(lLabel, mValue, identifier, { :unit=>context[:object]["unit"],
                                                                                :precision=>context[:object]["precision"] });
                case "state":
                    for(var i = 0; i < context[:object]["scopes"].size(); ++i) {
                        var scope = context[:object]["scopes"][i];
                        if(scope["value"] != null) {
                            if(mValue.toString().equals(scope["value"].toString())) {
                                return createMenuItem(identifier, true, getTempContext(context, scope));
                            }
                        }
                        else {
                            var val = mValue.toNumber();
                            if(val == null) {
                                continue;
                            }
                            if(scope["min"] == null) {
                                if(val <= scope["max"].toNumber()) {
                                    return createMenuItem(identifier, true, getTempContext(context, scope));
                                }
                            }
                            else if(scope["max"] == null) {
                                if(val >= scope["min"].toNumber()) {
                                    return createMenuItem(identifier, true, getTempContext(context, scope));
                                }
                            }
                            else {
                                if(val >= scope["min"].toNumber() && val <= scope["max"].toNumber()) {
                                    return createMenuItem(identifier, true, getTempContext(context, scope));
                                }
                            }
                        }
                    }
                    return new ObjectTextMenuItem(lLabel, mValue, identifier, { :unit=>" ?!" });
                default:
                    if(asState) {
                        var oIcon = new WatchUi.Text({  :text=>ioBrokerUtil.getIconId(context[:object]["type"], mapFrom(context[:object], mValue)),
                                                        :color=>ioBrokerUtil.getColor(context[:object]["color"], Graphics.COLOR_BLUE),
                                                        :backgroundColor=>Graphics.COLOR_BLACK,
                                                        :font=>context[:font]
                                                    });
                        return new ObjectStateMenuItem(lLabel, identifier, { :icon=>oIcon });
                    }
                    else {
                        return new ObjectToggleMenuItem(lLabel, identifier, mValue, {   :mapTrue=>context[:object]["true"],
                                                                                        :mapFalse=>context[:object]["false"] });
                    }
            }
        }
        else {
            return new ObjectCommandMenuItem(lLabel, identifier, {  :setIoState=>context[:setIoState], 
                                                                    :setter=>context[:object]["set"],
                                                                    :command=>context[:object]["value"] });
        }
    }

    function onIoState(id, value) {
        mValue = value;
    }

    function mapFrom(object, value) {
        if(object["true"] == null && object["false"] == null){
            return value;
        }
        return object["true"] != null ? value == object["true"] : value != object["false"];
    }

    function getTempContext(context, scope) {
        return {    :object     => {    "name"      => context[:object]["name"],
                                        "get"       => context[:object]["get"],
                                        "type"      => scope["type"],
                                        "color"     => scope["color"] != null ? scope["color"] : context[:object]["color"],
                                        "unit"      => scope["unit"] != null ? scope["unit"] : context[:object]["unit"],
                                        "precision" => scope["precision"] != null ? scope["precision"] : context[:object]["precision"], },
                    :getIoState => context[:getIoState],
                    :font       => context[:font] };
    }
}

class ObjectToggleMenuItem extends WatchUi.ToggleMenuItem {
    protected var mOptions;

    function initialize(label, identifier, enabled, options) {
        mOptions = options;
        ToggleMenuItem.initialize(label, "", identifier, mapFrom(enabled), options);
    }

    function execute() {
        if(mOptions[:setter] == null) {
            setEnabled(!isEnabled()); // reset to hold original state (only display)
        }
        else {
            mOptions[:setIoState].invoke(mOptions[:setter], mapTo(isEnabled()), null);
        }
        return true;
    }

    function mapFrom(value) {
        if(mOptions[:mapTrue] == null && mOptions[:mapFalse] == null){
            return value;
        }
        return mOptions[:mapTrue] != null ? value == mOptions[:mapTrue] : value != mOptions[:mapFalse];
    }
    function mapTo(value) {
        if(value && mOptions[:mapTrue] != null) {
            return mOptions[:mapTrue];
        }
        if(!value && mOptions[:mapFalse] != null) {
            return mOptions[:mapFalse];
        }
        return value;
    }
}

class ObjectCommandMenuItem extends WatchUi.MenuItem {
    protected var mOptions;

    function initialize(label, identifier, options ) {
        mOptions = options;
        MenuItem.initialize(label, "", identifier, options);
    }

    function execute() {
        mOptions[:setIoState].invoke(mOptions[:setter], mOptions[:command], null);
        return true;
    }
}

class ObjectStateMenuItem extends WatchUi.IconMenuItem {
    protected var mOptions;

    function initialize(label, identifier, options) {
        mOptions = options;
        IconMenuItem.initialize(label, "", identifier, options[:icon], options);
    }

    function execute() {
        return; // display only
    }
}

class ObjectTextMenuItem extends WatchUi.MenuItem {
    protected var mOptions;

    function initialize(label, value, identifier, options) {
        mOptions = options;
        MenuItem.initialize(label, "", identifier, options);
        setSubLabel(buildText(value));
    }

    function execute() {
        return; // display only
    }

    function buildText(value){
        var text = "";
        switch(value){
            case instanceof String:
                text = value;
                break;
            default:
                var pattern = "%d";
                if(mOptions[:precision] != null && mOptions[:precision].toNumber() >= 0) {
                    pattern = Lang.format("%1.$1$f", [mOptions[:precision].toNumber().format("%d")]);
                }
                text = value.format(pattern);
                break;
        }
        if(mOptions[:unit] != null){
            text += mOptions[:unit];
        }
        return text;
    }
}