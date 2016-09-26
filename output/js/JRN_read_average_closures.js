function read_average_closures() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#averageClosures');

    if (data['AverageClosures']=="0"){

        node.innerHTML = "less than 1";
    } else {
        
        node.innerHTML = data['AverageClosures'];  

    }


    

  });

}