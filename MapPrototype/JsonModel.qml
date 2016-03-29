import QtQuick 2.0

Item {
    id: wrapper

    signal newobject(var magneto)
    property variant model: housetrailDetails
    property string phrase : ""
    property string searchString: ""

    property int status: XMLHttpRequest.UNSENT
    property bool isLoading: status === XMLHttpRequest.LOADING
    property bool wasLoading: false
    property bool shouldEncode: true//default. due to problems with encoding on serverside. switched off in routesearch
    signal isLoaded

    ListModel { id: housetrailDetails }

    function encodePhrase(x) {
        return (shouldEncode) ? encodeURIComponent(x) : x;
        //return encodeURIComponent(x);
    }

    function reload() {
        housetrailDetails.clear()

        if (phrase == "")
            return;

//! [requesting]
        var req = new XMLHttpRequest;
        var searchPhrase = searchString.trim() + encodePhrase(phrase.trim()) //escape(phrase)
        //console.log(searchPhrase)
        req.open("GET", searchPhrase);
//        req.open("GET",searchString + base64Phrase);
        //console.log(req.responseText)

        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                //console.log(req.responseText)
                var searchResult = JSON.parse(req.responseText);
                if (searchResult.errors !== undefined)
                    console.log("Error fetching searchresults: " + searchResult.errors[0].message)
                else {
                   newobject(searchResult)
                }
                if (wasLoading == true)
                    wrapper.isLoaded()
            }
            wasLoading = (status === XMLHttpRequest.LOADING);
        }
        req.send();
//! [requesting]
    }

    onPhraseChanged: reload();


}
