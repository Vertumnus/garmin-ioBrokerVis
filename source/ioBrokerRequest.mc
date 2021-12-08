using Toybox.Communications;
using Toybox.Timer;

class ioBrokerRequest{
    enum{
        Init,
        NoDefinition,
        Loaded,
        RequestGet,
        RequestSet,
        Error,
        Finished
    }

    private var mDefinitionCallback;
    private var mGetterCallback;
    private var mFinishCallback;
    private var mErrorCallback;
    private var mAttribute;
    private var mState;

    private var mDemoState;

    private var mTimer;
    private var mGetterRequests;

    function initialize(getterCallback, definitionCallback, finishCallback){
        mDefinitionCallback = definitionCallback;
        mGetterCallback = getterCallback;
        mFinishCallback = finishCallback;
        mState = Init;
        mDemoState = Application.loadResource(Rez.JsonData.DemoState);
        mGetterRequests = [];
    }

    function hasConnectionError(){
        return mState == NoDefinition;
    }

    function isDemo(){
        return Application.Properties.getValue("url").equals("http://www.example.com");
    }

    function isFinished(){
        return mState == Finished;
    }

    function isReady(){
        return mState != Init && mState != NoDefinition;
    }

    function getAuthParameter(){
        var sUser = Application.Properties.getValue("user");
        var sPassword = Application.Properties.getValue("pass");
        var dParams = {};
        if(sUser != ""){
            dParams["user"] = sUser;
        }
        if(sPassword != ""){
            dParams["pass"] = sPassword;
        }
        return dParams;
    }

    function getGetterUrl(id){
        return Application.Properties.getValue("url") + "/getBulk/" + id;
    }

    function getSetterUrl(id){
        return Application.Properties.getValue("url") + "/set/" + id;
    }

    function getIdList(aIds){
        var sList = "";
        for(var i = 0; i < aIds.size(); ++i){
            if(sList != ""){
                sList += ",";
            }
            sList += aIds[i];
        }

        return sList;
    }

    function waitGetState(parameters, oCallback){
        mGetterRequests.add({ "callback"=>oCallback, "params"=>parameters });
        if(mTimer != null){
            return;
        }
        mTimer = new Timer.Timer();
        mTimer.start(method(:checkState), 100, true);
    }

    function checkState(){
        if(isFinished()){
            mTimer.stop();
            mTimer = null;
            for(var i = 0; i < mGetterRequests.size(); ++i){
                mGetterRequests[i]["callback"].invoke(mGetterRequests[i]["params"]["id"], mGetterRequests[i]["params"]["meth"]);
            }
            mGetterRequests = [];
        }
    }

    function loadDemo(){
        var aDemoData = Application.loadResource(Rez.JsonData.Demo);
        onDefinitionLoaded(200, aDemoData);
    }

    function loadDefinition(){

        if(isDemo()){
            System.println("use definition from demo");
            new Timer.Timer().start(method(:loadDemo), 1000, false);
            return;
        }

        System.println("load definition from: " + Application.Properties.getValue("defobj"));
        var sUrl = Application.Properties.getValue("url") + "/get/" + Application.Properties.getValue("defobj");
        var dParams = getAuthParameter();
        Communications.makeWebRequest(sUrl, dParams, {
            :method=>Communications.HTTP_REQUEST_METHOD_GET,
            :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onDefinitionLoaded));
    }

    function onDefinitionLoaded(code, data){
        if(code == 200){
            mState = Loaded;
            mDefinitionCallback.invoke(data["native"]["spaces"]);
        }
        else{
            mState = NoDefinition;
            System.println("IO Definition - error code: " + code);
            mDefinitionCallback.invoke(null);
        }
    }

    function get(aIds){
        mState = RequestGet;
        mAttribute = "val";

        if(isDemo()){
            var aStates = [];
            for(var i = 0; i < aIds.size(); ++i){
                aStates.add({ "id"=>aIds[i], "val"=>mDemoState[aIds[i]] });
            }
            onReceive(200, aStates);
            return;
        }

        System.println("get: " + aIds);
        var dParams = getAuthParameter();
        Communications.makeWebRequest(getGetterUrl(getIdList(aIds)), dParams, {
            :method=>Communications.HTTP_REQUEST_METHOD_GET,
            :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onReceive));
    }

    function set(id, value){
        mState = RequestSet;
        mAttribute = "value";

        if(isDemo()){
            mDemoState[id] = value;
            onReceive(200, { "id"=>id, "value"=>value });
            return;
        }

        System.println("set: " + id + " = " + value);
        var dParams = getAuthParameter();
        dParams["value"] = value;
        Communications.makeWebRequest(getSetterUrl(id), dParams, {
            :method=>Communications.HTTP_REQUEST_METHOD_GET,
            :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onReceive));
    }

    function onReceive(code, data){
        if(code == 200){
            if(mGetterCallback == null){
                mState = Finished;
                return;
            }
            var aResult;
            if(mState == RequestGet){
                aResult = data;
            }
            else{
                aResult = [data];
            }
            for(var i = 0; i < aResult.size(); ++i){
                mGetterCallback.invoke(aResult[i]["id"], aResult[i][mAttribute]);
            }
            if(mFinishCallback instanceof Lang.Method){
                mFinishCallback.invoke();
            }
            mState = Finished;
        }
        else{
            mState = Error;
            System.println("IO State - error code: " + code);
        }
    }
}