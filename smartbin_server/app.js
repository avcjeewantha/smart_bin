let express = require('express');
let app = express();
let port = 8080;
let sd = require('./dataSave');

app.use(function (req, res, next) {                 // Middleware for express requests and responses
    res.header("Access-Control-Allow-Origin", '*');                       // update to match the domain you will make the request from
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept,x-atlassian-mau-ignore");
    next();
});

/**
 * <p>
 * Endpoint that callabl;e to update the firebase database
 */
app.post("/update", function (req, res) {
    try {
        console.info("Received a Post request to the address \"/update\"");                     // request for get boundaries for a sprint list
        let body = [];
        req.on('data', (chunk) => {
            body.push(chunk);                                                                    // collect request data
        }).on('end', () => {
            // on end of data, perform necessary action
            body = Buffer.concat(body).toString();                                              // concat data chunks
            body = JSON.parse(body);
            let status = body["status"];
            let binId = body["id"];

            console.info ("Data received ...");
            sd.saveData(binId,status,(data)=>{
                res.status(200).send(data);
            }, (error)=>{
                res.status(404).send(error);
            });


            console.info("Response for /update request was sent...");
        });
    } catch (e) {
        res.status(500).send(e);
    }


});

let server = app.listen(port, function () {
    let host = server.address().address;                                            // Initialization of the server
    let port = server.address().port;

    console.log("Smart Bin Server application is listening at http://%s:%s", host, port)
});
