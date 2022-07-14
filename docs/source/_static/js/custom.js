// The functions here are used to update the methods description on the 
// Boilerplate page. They are executed when the user submits the form 
// embedded on that page.

function generateText() {
	makeModule1Text();
	makeModule2Text();
}

// An example for a checkbox option
function makeModule1Text() {
	let checked = document.getElementById("opt1").checked;
	let module1Desc = document.getElementById("module1");
	
	if (checked) {		
		module1Desc.innerHTML = "This is updated text for module 1.";
	} else {
		module1Desc.innerHTML = "This is placeholder text for module 1 to illustrate what we can do.";
	}
}


// Another example for a dropdown menu option
function makeModule2Text() {
	let select = document.getElementById("opt2");
	let choice = select.options[select.selectedIndex].value;
	let module2Desc = document.getElementById("module2");
	
	if (choice == "one"){
		module2Desc.innerHTML = "The user picked choice 1 for module 2.";
	} else if (choice == "two"){
		module2Desc.innerHTML = "The user picked choice 2 for module 2.";
	}  else if (choice == "three"){
		module2Desc.innerHTML = "The user picked choice 3 for module 2.";
	}
}
