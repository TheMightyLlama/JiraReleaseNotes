function read_project_title() {

  $.getJSON("json/ProjectVersion.json", function(data) {

    var node = document.querySelector('#fixVersion1');
    node.innerHTML = data['FixVersion'];  

    var node = document.querySelector('#fixVersion2');
    node.innerHTML = data['FixVersion']; 

  });

}