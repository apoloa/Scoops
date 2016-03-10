/**
  Custom API: getsasurl
**/



var azure = require('azure');
var qs = require('querystring');

exports.get = function(request, response) {

   // en el parametro nos llega el nombre del blob
   var blobName = request.query.blobName;
   var containerName = request.query.ContainerName;
   
   
   var accountName = "scoopsapstore";
   
   var accountKey =  "2EMjjaf/9ZkI8H1is4IR65CRctkrmM3KpE15zReF0pffJ3wWsFCJRKCHfgQJYlY+R0pdPQ0lCzWxNL1/AVL6dw==";
   
   var host = accountName + '.blob.core.windows.net/';
   
   console.log("La URL antes de la SAS es -> " + host );
   
   
   var blobService = azure.createBlobService(accountName, accountKey, host);

    var sharedAccessPolicy;
    sharedAccessPolicy = {
        AccessPolicy: {
            Permissions: 'rw',
            Expiry: minutesFromNow(15)
        }

    };

    var sasURL = blobService.generateSharedAccessSignature(containerName, '', sharedAccessPolicy);
   

    //console.log('SAS ->' + String.stringify(sasURL));

    var sasQueryString = { 'sasUrl' : sasURL.path + '?' + qs.stringify(sasURL.queryString) };

    console.log('resultado -> ' + sasQueryString);
   request.respond(200, sasQueryString);
       
};

function formatDate(date) { 
   var raw = date.toJSON(); 
   // Blob service does not like milliseconds on the end of the time so strip 
   return raw.substr(0, raw.lastIndexOf('.')) + 'Z'; 
}

function minutesFromNow(minutes) {
   var date = new Date();
   date.setMinutes(date.getMinutes() + minutes);
   return date;
}