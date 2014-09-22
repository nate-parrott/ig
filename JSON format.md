# JSON format

QUIZ:
{
	title: "",
	pageCount: #,
	items: []
}

item:
{
	type: true-false | multiple-choice | free-response | name-field | title
	pointValue: #,
	description: ""
	// after grading:
	earnedPoints: #,
}

## items

for multiple-choice items:
{
	options: <# of options>
	correct: <index of correct>
	frames: [frames of each]
	// after grading:
	response: #
}

for true-false:
{
	correct: bool
	// after grading:
	response: bool
}

for name-field, free-response:
{
	frame: <a frame>
}

## frames
arrays of 5 floats.
first is the page # that this item appears on
last 4 are left, top, right, bottom, from 0..1

