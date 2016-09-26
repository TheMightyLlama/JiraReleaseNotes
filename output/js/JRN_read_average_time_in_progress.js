function read_average_time_in_progress() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#averageTimeInProgress');
    node.innerHTML = data['AverageTimeInProgress'];  

  });

}