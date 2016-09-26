function read_version_logo() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#versionLogo');
    versionString = data['FixVersion'];  

    if (versionString.indexOf("HTML") !=-1) {

            node.innerHTML = '<img class="img-responsive" vspace="10" src="http://www.w3.org/html/logo/downloads/HTML5_Badge_512.png" alt="" height="42" width="42">';  

    } else if (versionString.indexOf("Android") !=-1){

            node.innerHTML = '<img class="img-responsive" vspace="10" src="http://onlythebestjokes.com/wp/wp-content/uploads/2014/02/android_icon_256.png" alt="" height="42" width="42">';  

    } else if (versionString.indexOf("iPhone") !=-1){

            node.innerHTML = '<img class="img-responsive" vspace="10" src="http://www.v3.co.uk/IMG/233/280233/silver-apple-logo-apple-picture.jpg" alt="" height="70" width="70">';  

    } else if (versionString.indexOf("Archiver") !=-1){

            node.innerHTML = '<img class="img-responsive" vspace="10" src="http://www.dreamscoder.com/images/Languages/java.png" alt="" height="80" width="80">';  

    } else {

            node.innerHTML = '<img class="img-responsive" vspace="10" src="http://img.clubic.com/05909628-photo-logo-libon.jpg" alt="" height="42" width="42">';  

    }





     


  });

}

