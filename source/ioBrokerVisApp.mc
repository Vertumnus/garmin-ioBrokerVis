using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Timer;

class ioBrokerVisApp extends Application.AppBase {

    private var mSpaces;
    private var mCurrentSpace;
    private var mIoStates;
    public var mIoRequest;
    private var mViewItems;

    private var mDemoStates;

    public var GioBFont;
    public var aPositions;


    function initialize() {
        AppBase.initialize();
        mSpaces = [];
        mCurrentSpace = 0;
        mIoStates = {};
        mIoRequest = new ioBrokerRequest(method(:onReceiveState), method(:onDefinitionLoaded), method(:onRequestFinished));

        GioBFont = WatchUi.loadResource(Rez.Fonts.giob);
        aPositions = WatchUi.loadResource(Rez.JsonData.DevicePositions);
    }

    function isDemo(){
        return Application.Properties.getValue("url").equals("http://www.example.com");
    }

    function loadDemo(){
        mDemoStates = WatchUi.loadResource(Rez.JsonData.DemoState);
        mIoRequest.onDefinitionLoaded(200, WatchUi.loadResource(Rez.JsonData.Demo));
    }

    function onDemoData(id, value){
        if(value != null){
            mDemoStates[id] = value;
        }
        return mDemoStates[id];
    }

    function connect(){
        WatchUi.pushView(new WatchUi.ProgressBar("...I.O...", null), null, WatchUi.SLIDE_BLINK);
        if(isDemo()){
            mIoRequest.setDataCallback(method(:onDemoData));
            new Timer.Timer().start(method(:loadDemo), 1000, false);
        }
        else{
            mIoRequest.setDataCallback(null);
            mIoRequest.loadDefinition();
        }
    }

    function getIoState(id, oMethod){
        if(mIoRequest.isFinished()){
            oMethod.invoke(id, (mIoStates[id] != null)?mIoStates[id]:"");
        }
        else{
            mIoRequest.waitGetState({ "id"=>id, "meth"=>oMethod }, method(:getIoState));
        }

        return me;
    }

    function setIoState(id, value, oMethod){
        var oRequest = new ioBrokerRequest(oMethod, null, null);
        if(isDemo()){
            oRequest.setDataCallback(method(:onDemoData));
        }
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
        mViewItems = [];

        ++mCurrentSpace;
        if(mCurrentSpace >= mSpaces.size()){
            mCurrentSpace = 0;
        }
        requestCurrentIoStates();

        return me;
    }

    function previousSpace(){
        mViewItems = [];

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