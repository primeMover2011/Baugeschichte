import QtQuick 2.0
//import "tweetsearch.js" as Helper

Item {
    id: wrapper

    property variant model: housetrailDetails
    property string phrase : ""
    property string searchString: ""

    property int status: XMLHttpRequest.UNSENT
    property bool isLoading: status === XMLHttpRequest.LOADING
    property bool wasLoading: false
    signal isLoaded

    ListModel { id: housetrailDetails }

    function encodePhrase(x) { return encodeURIComponent(x); }

    function reload() {
        housetrailDetails.clear()

        if (phrase == "")
            return;

//! [requesting]
        var req = new XMLHttpRequest;

        req.open("GET",searchString + encodePhrase(phrase));

        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                var searchResult = JSON.parse(req.responseText);
                if (searchResult.errors !== undefined)
                    console.log("Error fetching searchresults: " + searchResult.errors[0].message)
                else {
                    for (var key in searchResult) {
                        var jsonObject = searchResult[key];
                        jsonObject.detailText=jsonObject.text
                        jsonObject.text = ""
                        housetrailDetails.append(jsonObject);
                    }
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
