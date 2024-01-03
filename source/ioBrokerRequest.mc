using Toybox.Communications;

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
    private var mAttribute;
    private var mState;

    private var mDataCallback;

    public var mErrorCode;

    function initialize(getterCallback, definitionCallback, finishCallback){
        mDefinitionCallback = definitionCallback;
        mGetterCallback = getterCallback;
        mFinishCallback = finishCallback;
        mState = Init;
    }

    function setDataCallback(dataCallback){
        mDataCallback = dataCallback;
    }

    function hasConnectionError(){
        return mState == NoDefinition;
    }

    function hasError(){
        return mState == Error;
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

    function loadDefinition(){
        mState = Init;
        System.println("load definition from: " + Application.Properties.getValue("defobj"));
        var sUrl = Application.Properties.getValue("url") + "/get/" + Application.Properties.getValue("defobj");
        var dParams = getAuthParameter();
        Communications.makeWebRequest(sUrl, dParams, {
            :method=>Communications.HTTP_REQUEST_METHOD_GET,
            :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onDefinitionLoaded));
    }

    function onDefinitionLoaded(code as Toybox.Lang.Number, data as Toybox.Lang.Dictionary) as Void{
        mErrorCode = code;
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

        if(mDataCallback != null){
            var dStates = {};
            for(var i = 0; i < aIds.size(); ++i){
                var value = mDataCallback.invoke(aIds[i], null);
                dStates.put(i, { "id"=>aIds[i], "val"=>value });
            }
            onReceive(200, dStates);
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

        if(mDataCallback != null){
            mDataCallback.invoke(id, value);
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

    function onReceive(code as Toybox.Lang.Number, data as Toybox.Lang.Dictionary) as Void{
        if(code == 200){
            if(mGetterCallback == null){
                mState = Finished;
                return;
            }
            var aResult;
            if(mState == RequestGet){
                if(data instanceof Toybox.Lang.Array){
                    aResult = data;
                }
                else{
                    aResult = data.values();
                }
            }
            else{
                aResult = [data];
            }
            for(var i = 0; i < aResult.size(); ++i){
                mGetterCallback.invoke(aResult[i]["id"], aResult[i][mAttribute]);
            }
            mState = Finished;
        }
        else{
            mState = Error;
            System.println("IO State - error code: " + code);
        }
        if(mFinishCallback instanceof Lang.Method){
            mFinishCallback.invoke();
        }
    }
}