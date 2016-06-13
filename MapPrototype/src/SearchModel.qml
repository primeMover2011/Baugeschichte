import QtQuick 2.0
//import "tweetsearch.js" as Helper

Item {
    id: wrapper

    property variant model: housetrails
    property string phrase : ""
    property string searchString: ""

    property int status: XMLHttpRequest.UNSENT
    property bool isLoading: status === XMLHttpRequest.LOADING
    property bool wasLoading: false
    signal isLoaded

    ListModel { id: housetrails }

    function encodePhrase(x) { return encodeURIComponent(x); }

    function reload() {
        housetrails.clear()

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
                    for (var key in searchResult.query.search) {
                        var jsonObject = searchResult.query.search[key];
                        housetrails.append(jsonObject);
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
