using Toybox.WatchUi;

class SpaceMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(oItem) {
        return oItem.execute();
    }
}