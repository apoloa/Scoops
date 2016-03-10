/**
  Custom API: SetsScore
**/


exports.post = function(request, response) {
    var id = request.query.id
    var score = request.query.score
    
    console.log("Setting Score:  " + id + " - score: " + score )
    
    var mssql = request.service.mssql;
    var sql = "SELECT score, total_likes FROM news where id='" + id + "'";
    mssql.query(sql, {
       success: function(results){
           var scoreSQL = results[0].score;
           console.log(typeof scoreSQL)
           console.log(typeof score)
           var totalLikes = results[0].total_likes;
           scoreSQL += Number(score);
           totalLikes += 1;
           var updateSQL = "UPDATE news SET score="+ scoreSQL +", total_likes="+totalLikes+" where id='"+id+"'";
           mssql.query(updateSQL, {
               success: function(results){
                   response.send(200, {"results":results})
               },
               error: function(error){
                   response.send(500, {"error":error})
               }
           });
       },
       error: function(error){
           response.send(500, {"error":error})
       }
    });
};