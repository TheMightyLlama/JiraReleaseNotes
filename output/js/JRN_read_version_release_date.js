function read_version_release_date() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#releaseDate');
    
    var releaseString = data['ReleaseDate'];
    console.log(releaseString);

    if (releaseString == "null") {

            node.innerHTML = "Unreleased";  

    } else {
            node.innerHTML = releaseString;          
    }


  });

}