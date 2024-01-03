using Toybox.WatchUi;

class SpaceMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(oItem) {
        (oItem as ObjectToggleMenuItem or ObjectCommandMenuItem or ObjectStateMenuItem or ObjectTextMenuItem).execute();
    }
}