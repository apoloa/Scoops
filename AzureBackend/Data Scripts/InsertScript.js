/*
 Insert Script
*/

function insert(item, user, request) {
    console.log("Saving new News");
    // Setting default values
    item.score = 0
    item.total_likes = 0
    var error = false
    if(item.title === ""){
         request.respond(statusCodes.BAD_REQUEST, 'Text must be required');
         error = true;
    } 
    if(item.text.length < 10){
         request.respond(statusCodes.BAD_REQUEST, 
            'Body length must be more than 10 characters');
            error = true;
    }
    if(item.photo === ""){
        request.respond(statusCodes.BAD_REQUEST, 'Photo must be required');
        error = true;
    }
    if (!error){
        user.getIdentities({
        success: function (identities) {
            var http = require('request');
            console.log('Identities: ', identities);
            var url = 'https://graph.facebook.com/me?fields=id,name,birthday,hometown,email,picture,gender,friends&access_token=' +
                identities.facebook.accessToken;
 
            var reqParams = { uri: url, headers: { Accept: 'application/json' } };
            http.get(reqParams, function (err, resp, body) {
                var userData = JSON.parse(body);
                console.log('Logado -> ' + userData.name);
                item.author = userData.id;
                item.authorName = userData.name
                request.execute();
                });
            }
        });
    }
}