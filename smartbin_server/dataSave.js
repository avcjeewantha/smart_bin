const admin = require('firebase-admin');
let http = require('http');

let serviceAccount = require('./smart-bin-273112-6339b0df47cc.json');
let locationJson = JSON.parse(JSON.stringify(require("./location.json")));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

let db = admin.firestore();

/**
 * Created by Sandun Gunasekara on 06/08/20.
 * Function to save data into firebase
 * @type {{saveData: saveData}}
 */

module.exports = {
    saveData: function (binId,binStatus,successCallback,errorCallback) {
        console.info("Connecting into firebase ...");
        try {
            let docRef = db.collection('Bin').doc(binId);

            let setAda = docRef.set({
                longitude: locationJson[binId]["longitude"],
                latitude: locationJson[binId]["latitude"],
                status: binStatus
            });
            console.info("Bin status: "+binStatus+" saved successfully for bin id: "+binId+"...");
            successCallback("Bin status: "+binStatus+" saved successfully for bin id: "+binId+"...");
        } catch (e) {
            errorCallback(e);
        }

    }
}
