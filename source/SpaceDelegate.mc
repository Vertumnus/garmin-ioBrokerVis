using Toybox.Lang;
using Toybox.WatchUi;

class SpaceDelegate extends WatchUi.BehaviorDelegate {

    function initialize(){
        BehaviorDelegate.initialize();
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSelectable(oEvent){
        var oSelectable = oEvent.getInstance();
        if(oSelectable instanceof ObjectSwitch){
            oSelectable.change(oEvent.getPreviousState(), oSelectable.getState());
        }
        if(oSelectable instanceof ObjectButton){
            oSelectable.execute();
        }
        return true;
    }

    function onKey(oEvent) {
        if(oEvent.getKey() == WatchUi.KEY_ENTER) {
            Application.getApp().refreshViewItems();
        }
    }

    function onMenu(){
        var dSpace = Application.getApp().getCurrentSpace();
        if(dSpace == null){
            return;
        }
        
        var oMenu = new WatchUi.Menu2({:title=>(dSpace["name"]!=null)?dSpace["name"]:Rez.Strings.options});
        var oObjectMenuFactory = new ObjectMenuItemFactory();

        var aObjects = dSpace["objects"];
        for(var i = 0; i < aObjects.size(); ++i){
            oMenu.addItem(oObjectMenuFactory.createMenuItem(i, false, {     :object     => aObjects[i],
                                                                            :getIoState => new Lang.Method(Application.getApp(), :getIoState),
                                                                            :setIoState => new Lang.Method(Application.getApp(), :setIoState),
                                                                            :font       => Application.getApp().GioBFont }));
        }

        WatchUi.pushView(oMenu, new SpaceMenuDelegate(), WatchUi.SLIDE_BLINK);
    }

    function onNextPage(){
        Application.getApp().nextSpace();
        WatchUi.cancelAllAnimations();
        WatchUi.switchToView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage(){
        Application.getApp().previousSpace();
        WatchUi.cancelAllAnimations();
        WatchUi.switchToView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    function onRefresh(){
        Application.getApp().refreshViewItems();
    }

}