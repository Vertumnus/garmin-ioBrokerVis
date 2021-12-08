using Toybox.Application;
using Toybox.WatchUi;

class ioBrokerVisApp extends Application.AppBase {

    private var mSpaces;
    private var mCurrentSpace;
    private var mIoStates;
    private var mIoRequest;
    private var mViewItems;

    function initialize() {
        AppBase.initialize();
        mSpaces = [];
        mCurrentSpace = 0;
        mIoStates = {};
        mIoRequest = new ioBrokerRequest(method(:onReceiveState), method(:onDefinitionLoaded), method(:onRequestFinished));
    }

    function connect(){
        WatchUi.pushView(new WatchUi.ProgressBar("...I.O...", null), null, WatchUi.SLIDE_BLINK);
        mIoRequest.loadDefinition();
    }

    function getIoState(id, oMethod){
        if(mIoRequest.isFinished()){
            oMethod.invoke(id, mIoStates[id]);
        }
        else{
            mIoRequest.waitGetState({ "id"=>id, "meth"=>oMethod }, method(:getIoState));
        }

        return me;
    }

    function setIoState(id, value, oMethod){
        var oRequest = new ioBrokerRequest(oMethod, null, null);
        oRequest.set(id, value);

        return me;
    }

    function requestCurrentIoStates(){
        if(!isSpaceReady()){
            return me;
        }
        var aObjects = getCurrentSpace()["objects"];
        var aIds = [];
        for(var i = 0; i < aObjects.size(); ++i){
            if(aObjects[i]["get"] != null){
                aIds.add(aObjects[i]["get"]);
            }
        }
        mIoStates = {};
        if(aIds.size() > 0){
            mIoRequest.get(aIds);
        }

        return me;
    }

    function onReceiveState(id, value){
        mIoStates[id] = value;
    }

    function onDefinitionLoaded(spaces){
        if(spaces != null){
            mSpaces = spaces;
        }
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

    function onRequestFinished(){
        WatchUi.requestUpdate();
    }

    function hasConnectionError(){
        return mIoRequest.hasConnectionError();
    }

    function isConnectionReady(){
        return mIoRequest.isReady();
    }

    function isSpaceReady(){
        return mSpaces.size() > 0;
    }

    function getCurrentSpace(){
        if(isSpaceReady()){
            return mSpaces[mCurrentSpace];
        }
        else{
            return [];
        }
    }

    function nextSpace(){
        ++mCurrentSpace;
        if(mCurrentSpace >= mSpaces.size()){
            mCurrentSpace = 0;
        }
        requestCurrentIoStates();

        return me;
    }

    function previousSpace(){
        --mCurrentSpace;
        if(mCurrentSpace < 0){
            mCurrentSpace = mSpaces.size() - 1;
        }
        requestCurrentIoStates();

        return me;
    }

    function setViewItems(aItems){
        mViewItems = aItems;

        return me;
    }

    function refreshViewItems(){
        requestCurrentIoStates();
        for(var i = 0; i < mViewItems.size(); ++i){
            mViewItems[i].updateState(null);
        }

        return me;
    }

    function onSettingsChanged() {
        mSpaces = [];
        mCurrentSpace = 0;
        mIoStates = {};
        connect();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new MainView(), new MainDelegate() ];
    }

}