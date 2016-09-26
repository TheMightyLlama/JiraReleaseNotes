/*
/* x = Open / Closed
/* y = Story / Task / Bug
*/
function count_issues(x , y ) {

	$.getJSON("json/ProjectVersion.json", function(data) {

		if (y == "closed") {

			switch(x) {
				case 'stories':
				var node = document.querySelector('#closedStoryCount');
				node.innerHTML = data['ClosedStoryCount'];  
				break;

				case 'tasks':
				var node = document.querySelector('#closedTaskCount');
				node.innerHTML = data['ClosedTaskCount'];          
				break;

				case 'bugs':
				var node = document.querySelector('#closedBugCount');
				node.innerHTML = data['ClosedBugCount'];  
				break;


			}
		} else if (y == "open") {



			switch(x) {
				case 'stories':
				var node = document.querySelector('#openStoryCount');
				node.innerHTML = data['OpenStoryCount'];  
				break;

				case 'tasks':
				var node = document.querySelector('#openTaskCount');
				node.innerHTML = data['OpenTaskCount'];          
				break;

				case 'bugs':
				var node = document.querySelector('#openBugCount');
				node.innerHTML = data['OpenBugCount'];  
				break;


			}
		}
	});

}