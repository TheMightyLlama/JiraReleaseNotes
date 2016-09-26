function read_start_date() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#startDate');
    node.innerHTML = data['StartDate'];  

  });

}