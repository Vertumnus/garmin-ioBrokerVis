using Toybox.WatchUi;
using Toybox.Communications;

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

    function onNextPage(){
        Communications.cancelAllRequests();
        WatchUi.cancelAllAnimations();
        Application.getApp().nextSpace();
        WatchUi.switchToView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage(){
        Communications.cancelAllRequests();
        WatchUi.cancelAllAnimations();
        Application.getApp().previousSpace();
        WatchUi.switchToView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    function onRefresh(){
        Application.getApp().refreshViewItems();
    }

}