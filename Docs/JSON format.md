# JSON format

## quizzes

{
	title: "",
	pageCount: #,
	items: []
}

item:
{
	type: true-false | multiple-choice | free-response | name-field | title
	points: #,
	description: ""
	visibleIndex: # (1-indexed)
	// after grading:
	pointsEarned: #,
    gradingDescription: ""
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


## quiz instance uploads:
{quizInstances: [quiz instances]}

## graded quiz instances
...are sent via `msgpack`

{
	earnedScore:
	maximumScore:
	responseItems:
	quizIndex:
	timestamp:
	nameImage: <jpeg data>
}
