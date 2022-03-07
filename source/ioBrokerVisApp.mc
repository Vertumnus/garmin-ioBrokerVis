using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Timer;

class ioBrokerVisApp extends Application.AppBase {

    enum{
        Main,
        Space
    }

    private var mSpaces;
    private var mCurrentSpace;
    private var mIoStates;
    public var mIoRequest;
    private var mViewItems;
    private var mView;

    private var mDemoStates;

    public var GioBFont;
    public var aPositions;


    function initialize() {
        AppBase.initialize();
        mSpaces = [];
        mCurrentSpace = 0;
        mIoStates = {};
        mViewItems = [];
    }

    function atMain(){
        mView = Main;
    }

    function atSpace(){
        mView = Space;
    }

    function showsSpace(){
        return mView == Space;
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

    function showProgressBar(){
        WatchUi.pushView(new WatchUi.ProgressBar("...I.O...", null), null, WatchUi.SLIDE_BLINK);
    }

    function closeProgressBar(){
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

    function connect(){
        mSpaces = [];
        mCurrentSpace = 0;
        mIoStates = {};
        showProgressBar();
        if(isDemo()){
            mIoRequest.setDataCallback(method(:onDemoData));
            // take a second to enjoy the progress bar
            new Timer.Timer().start(method(:loadDemo), 1000, false);
        }
        else{
            mIoRequest.setDataCallback(null);
            mIoRequest.loadDefinition();
        }
    }

    function getIoState(id, oMethod){
        if(mIoStates[id] != null){
            oMethod.invoke(id, mIoStates[id]);
        }

        return me;
    }

    function setIoState(id, value, oMethod){
        var oRequest = new ioBrokerRequest(oMethod, null, null);
        if(isDemo()){
            oRequest.setDataCallback(method(:onDemoData));
        }
        oRequest.set(id, value);
        mIoStates[id] = value;

        return me;
    }

    function requestCurrentIoStates(){
        if(!isSpaceReady()){
            return me;
        }
        Communications.cancelAllRequests();
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
        // give the system some time to handle view stack (otherwise the app crashes)
        new Timer.Timer().start(method(:afterDefinitionLoaded), 100, false);
    }

    function afterDefinitionLoaded(){
        closeProgressBar();
        if(isSpaceReady()){
            requestCurrentIoStates();
            WatchUi.pushView(new SpaceView(), new SpaceDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function updateViewItems(){
        if(mViewItems.size() == 0){
            new Timer.Timer().start(method(:updateViewItems), 200, false);
        }
        else{
            for(var i = 0; i < mViewItems.size(); ++i){
                mViewItems[i].updateState(null);
            }
            WatchUi.requestUpdate();
        }
    }

    function onRequestFinished(){
        if(mIoRequest.isFinished()){
            updateViewItems();
        }
        else{
            WatchUi.requestUpdate();
        }
    }

    function hasConnectionError(){
        return mIoRequest.hasConnectionError();
    }

    function hasError(){
        return mIoRequest.hasError();
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
            return null;
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
        return me;
    }

    function onSettingsChanged() {
        if(showsSpace()){
            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }
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
        mIoRequest = new ioBrokerRequest(method(:onReceiveState), method(:onDefinitionLoaded), method(:onRequestFinished));
        GioBFont = WatchUi.loadResource(Rez.Fonts.giob);
        aPositions = WatchUi.loadResource(Rez.JsonData.DevicePositions);
        return [ new MainView(), new MainDelegate() ];
    }

    (:glance)
    function getGlanceView() {
        return [ new GlanceView() ];
    }

}