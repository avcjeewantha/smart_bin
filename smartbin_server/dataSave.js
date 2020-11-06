const admin = require('firebase-admin');
const fs = require('fs');
let http = require('http');

let serviceAccount = require('./smart-bin-273112-6339b0df47cc.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

let db = admin.firestore();

/**
 * Function to save data into firebase
 * @type {{saveData: saveData}}
 */

module.exports = {
    saveData: function (binId, binStatus, successCallback, errorCallback) {
        console.info("Reading Bin location info..");
        fs.readFile('location.json', function (err, data) {
            if (err) {
                console.info(err);
                errorCallback(err);
            } else {
                let locationJson = JSON.parse(data);
                console.info("Connecting into firebase ...");
                try {
                    let docRef = db.collection('Bin').doc(binId);

                    let setAda = docRef.set({
                        longitude: locationJson[binId]["longitude"],
                        latitude: locationJson[binId]["latitude"],
                        status: binStatus
                    });
                    console.info("Bin status: " + binStatus + " saved successfully for bin id: " + binId + "...");
                    successCallback("Bin status: " + binStatus + " saved successfully for bin id: " + binId + "...");
                } catch (e) {
                    console.info(e);
                    errorCallback(e.message);
                }
            }

        });

    },

    changeLocation: function (binId, latitude, longitude, successCallback, errorCallback) {

        let file = JSON.parse('{}');
        file['latitude'] = latitude;
        file['longitude'] = longitude;
        fs.readFile('location.json', function (err, data) {
            var json = JSON.parse(data);
            json[binId] = file;
            console.log(JSON.stringify(json));
            fs.writeFile("location.json", JSON.stringify(json), function writeJSON(err) {
                if (err) errorCallback(err);
                console.log(JSON.stringify(file));
                console.log('writing to location database..');
                successCallback("Location data saved successfully...");
            });
        });
    }
}
