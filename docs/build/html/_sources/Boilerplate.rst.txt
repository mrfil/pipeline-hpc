.. _Boilerplate :

.. |formstart| raw:: html

	<form name="module-options" id="options" action="javascript:generateText()">


.. |option1| raw:: html

	<label for="option1">
		Option 1
		<input type="checkbox" id="opt1">
		<br>This will change the content describing module 1.
	</label>

.. |option2| raw:: html

	<label for="option2">
	Option 2
	<select name="option-2" id="opt2">
		<option value="one">Choice 1</option>
		<option value="two">Choice 2</option>
		<option value="three">Choice 3</option>
	</select>
	<br>This will change the content describing module 2.
	<label>

.. |formend| raw:: html

	<input type="submit" value="Generate Text">
	</form>

.. |module1Text| raw:: html
	
	<span id="module1">This is placeholder text for module 1 to illustrate what we can do.</span>

.. |module2Text| raw:: html

	<span id="module2">This is placeholder text for module 2. But really, it could be blank.</span>



***********
Boilerplate
***********

|formstart|

|option1|

|option2|

|formend|


Methods Text
============
Some introductory text that never changes. |module1Text| |module2Text| Some concluding text that will never change.

