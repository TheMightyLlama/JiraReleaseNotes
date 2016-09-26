function read_json_closed_bugs() {
  
  $.getJSON("json/ClosedBugsList.json", function(data){
    
    console.log(data);
    $.each(data, function (index, value) {
        console.log(value);



      var table = document.getElementById("closed_bug_table");
      var row = table.insertRow(-1);
      var cell1 = row.insertCell(0);
      cell1.style.width = "30px";
      var cell2 = row.insertCell(1);
      cell2.style.width = "70px";
      var cell3 = row.insertCell(2);
      cell1.innerHTML = "<span class=\"glyphicon glyphicon-exclamation-sign red\" aria-hidden=\"true\"></span>";
      cell2.innerHTML = "<a href=\"https://your-jira-instance.com/jira/browse/"+value.key+"\">"+value.key+"</a>";
      cell3.innerHTML = value.summary;
      
    });
  }).fail( function(d, textStatus, error) {
console.error("getJSON failed, status: " + textStatus + ", error: "+error)
 });
    
}