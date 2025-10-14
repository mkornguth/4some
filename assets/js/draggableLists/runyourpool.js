<!--
var ESCAPE = 27
var ENTER = 13
var TAB = 9
var coordinates = ToolMan.coordinates()
var dragsort = ToolMan.dragsort()
var junkdrawer = ToolMan.junkdrawer()
window.onload = function() {
dragsort.makeListSortable(document.getElementById("playerList"), setHandle)
}
function setHandle(item) {
if (item.toolManDragGroup!=null) {
item.toolManDragGroup.setHandle(findHandle(item))
}
}
function findHandle(item) {
var children = item.getElementsByTagName("div")
for (var i = 0; i < children.length; i++) {
var child = children[i]
if (child.getAttribute("class") == null) continue
if (child.getAttribute("class").indexOf("handle") >= 0)
return child
}
return item
}
function join(name, isDoubleClick) {
var view = document.getElementById(name + "View")
view.editor = document.getElementById(name + "Edit")
var showEditor = function(event) {
event = fixEvent(event)
var view = this
var editor = view.editor
if (!editor) return true
if (editor.currentView != null) {
editor.blur()
}
editor.currentView = view
var topLeft = coordinates.topLeftOffset(view)
topLeft.reposition(editor)
if (editor.nodeName == 'TEXTAREA') {
editor.style['width'] = view.offsetWidth + "px"
editor.style['height'] = view.offsetHeight + "px"
}
editor.value = view.innerHTML
editor.style['visibility'] = 'visible'
view.style['visibility'] = 'hidden'
editor.focus()
return false
}
if (isDoubleClick) {
view.ondblclick = showEditor
} else {
view.onclick = showEditor
}
view.editor.onblur = function(event) {
event = fixEvent(event)
var editor = event.target
var view = editor.currentView
if (!editor.abandonChanges) view.innerHTML = editor.value
editor.abandonChanges = false
editor.style['visibility'] = 'hidden'
editor.value = '' // fixes firefox 1.0 bug
view.style['visibility'] = 'visible'
editor.currentView = null
return true
}
view.editor.onkeydown = function(event) {
event = fixEvent(event)
var editor = event.target
if (event.keyCode == TAB) {
editor.blur()
return false
}
}
view.editor.onkeyup = function(event) {
event = fixEvent(event)
var editor = event.target
if (event.keyCode == ESCAPE) {
editor.abandonChanges = true
editor.blur()
return false
} else if (event.keyCode == TAB) {
return false
} else {
return true
}
}
// TODO: this method is duplicated elsewhere
function fixEvent(event) {
if (!event) event = window.event
if (event.target) {
if (event.target.nodeType == 3) event.target = event.target.parentNode
} else if (event.srcElement) {
event.target = event.srcElement
}
return event
}
}
//build select objects on form submission to support legacy processor
function BuildConfidenceSelectObjects()
{
var isValid = true;
var gameList = document.getElementById("playerList").getElementsByTagName("li");
for (var i = 0;i < gameList.length; i++) {
var item = gameList[i]
var gameId = item.getAttribute("itemId");
var pointValue = 16-i;
//validate form before creating select objects
var gameArray = document.getElementById("li" + gameId).getElementsByTagName("input");
if (!gameArray[0].checked && !gameArray[1].checked) {
isValid = false;
alert("Warning: Missing Pick. Please select a winning team for your " + pointValue + " point selection.");
break;
}
//create select objects to hold point values
gameSelectObj = document.createElement("select");
gameSelectObj.name = gameId;
gameSelectObj.style.display = 'none';
gameSelectObj.options.add(new Option(gameId,pointValue));
document.forms["pickForm"].appendChild(gameSelectObj);
}
if (isValid) {
//FOR DEMO ONLY, PREVENTS FORM SUBMISSION
$('#myModal').modal('show');
isValid = false;
}
return isValid;
}
function selectBox(teamSelected,teamUnselected) {
if($(":radio[value="+teamSelected+"]").attr('disabled')) {
}
else {
document.getElementById("box"+teamSelected).style.backgroundColor="#ffffcc";
document.getElementById("box"+teamUnselected).style.backgroundColor="#eeeeee";
//$(":radio[value="+teamUnselected+"]").attr('checked',false);
$(":radio[value="+teamSelected+"]").prop('checked',true);
}
}
function touchHandler(event)
{
var touches = event.changedTouches,
first = touches[0],
type = "";
switch(event.type)
{
case "touchstart": type = "mousedown"; break;
case "touchmove": type="mousemove"; break;
case "touchend": type="mouseup"; break;
default: return;
}
var simulatedEvent = document.createEvent("MouseEvent");
simulatedEvent.initMouseEvent(type, true, true, window, 1,
first.screenX, first.screenY,
first.clientX, first.clientY, false,
false, false, false, 0/*left*/, null);
first.target.dispatchEvent(simulatedEvent);
event.preventDefault();
}
function validateTiebreak()
{
var tiebreak = document.getElementById('tiebreak').value;
if (tiebreak.length == 0){
alert('Please enter a valid tiebreak value');
return false;
}
}
//-->