function read_json_status_changes() {
  
  $.getJSON("json/FullMovedIssueList.json", function(data){
    
    console.log(data);
    $.each(data, function (index, value) {
        console.log(value);



      var table = document.getElementById("status_change_table");
      var row = table.insertRow(-1);
      var cell1 = row.insertCell(0);
      cell1.style.width = "30px";
      var cell2 = row.insertCell(1);
      cell1.style.width = "30px";              
      var cell3 = row.insertCell(2);
      cell2.style.width = "70px";
      var cell4 = row.insertCell(3);


      if (value.type=="Task"){

            cell1.innerHTML = "<span class=\"glyphicon glyphicon-check yellow\" aria-hidden=\"true\"></span>";

        } else if (value.type=="Story") {

            cell1.innerHTML = "<span class=\"glyphicon glyphicon-check green\" aria-hidden=\"true\"></span>";

        } else if (value.type=="Bug") {

            cell1.innerHTML = "<span class=\"glyphicon glyphicon-exclamation-sign red\" aria-hidden=\"true\"></span>";

        }

      cell2.innerHTML = "<a href=\"https://your-jira-instance.com/jira/browse/"+value.key+"\">"+value.key+"</a>";
      cell3.innerHTML = value.status;
      cell4.innerHTML = value.summary;
      
    });
  }).fail( function(d, textStatus, error) {
console.error("getJSON failed, status: " + textStatus + ", error: "+error)
 });
    
}