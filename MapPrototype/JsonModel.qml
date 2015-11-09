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
                console.log(req.responseText)
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
