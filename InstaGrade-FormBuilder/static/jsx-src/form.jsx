/** @jsx React.DOM */

var update = React.addons.update;

var generateUniqueId = function() {
	if (!window.lastUniqueId) window.lastUniqueId = 1;
	return "id" + (window.lastUniqueId++);
}

var setInnerText = function(node, text) {
	if (node.innerText === undefined) {
		node.textContent = text;
	} else {
		node.innerText = text;
	}
}

var getInnerText = function(node) {
	return node.innerText === undefined ? node.textContent : node.innerText;
}

var shouldDisplayHeaderForItem = function(item) {
	return ['multiple-choice', 'true-false', 'free-response', 'section'].indexOf(item.type) != -1;
}

var shouldCountItemAsQuestion = function(item) {
	return ['multiple-choice', 'true-false', 'free-response'].indexOf(item.type) != -1;
}

var shouldDisplayDescriptionForItem = function(item) {
	return ['multiple-choice', 'true-false', 'free-response'].indexOf(item.type) != -1;
}

var itemCanHavePointValue = function(item) {
	return ['multiple-choice', 'true-false', 'free-response'].indexOf(item.type) != -1;
}

var FormEditor = React.createClass({
	render: function() {
		var self = this;
		var visibleIndex = 0; // doesn't count items that don't display a header, like 'title'
		var renderedItems = this.state.items.map(function(item, index) {
			if (shouldCountItemAsQuestion(item)) {
				visibleIndex++;
			}
			var onChange = function(changes) {
				var updateCommand = {items: {}}
				updateCommand.items[index] = {$merge: changes}
				self.setState(update(self.state, updateCommand));
			}
			return <FormItem item={item} onItemChange={onChange} index={visibleIndex-1} key={item.id} onDragStart={self.dragStart} onDragEnd={self.dragEnd} onDragOver={self.dragOver} onDrop={self.drop} onDelete={self.deleteItem} />
		});
		var totalPoints = 0;
		this.state.items.forEach(function(item) {
			if (item.points) {
				totalPoints += item.points;
			}
		}); 
		var hasItems = totalPoints > 0;
		return <div className='formEditor'>
							<div className='sidebar'>
								<h1>InstaGrade</h1>
								<p>lets you create quizzes and tests on your computer, print them, then grade them automatically by taking a picture with our <a href='/download_scanner'>iPhone app</a>. We’ll email you the results.</p>
								<p>
									<a href='/how-it-works'>How it works</a>
								</p>
								<p>Your quiz has {visibleIndex} questions with {totalPoints} total points.</p>
								<form onSubmit={self.done}>
									<p>
										<input type='checkbox' onChange={this.updateSeparateAnswerSheetsFromQuestions} checked={this.state.separateAnswerSheetsFromQuestions} id='separateAnswerSheetsFromQuestions'/>
										<label htmlFor='separateAnswerSheetsFromQuestions'>Separate answer sheet from questions</label>
									</p>
									<input type='submit' value="Create Quiz" className='done'/>
								</form>
								<a href={LOGOUT_URL} style={{display: USER_EMAIL? "block" : "none"}}>Log out { USER_EMAIL }</a>
							</div>
							<div className='page'>
								<div className='items'>{renderedItems}</div>
							</div>
							<div className='page newItems'>
								<NewItemPicker onInsertItem={self.insertItem} hasItems={hasItems}/>
							</div>
					 </div>
	},
	updateState: function(changes) {
		var updateCommand = {$merge: changes};
		this.setState(update(this.state, updateCommand));
	},
	updateSeparateAnswerSheetsFromQuestions: function(e) {
		this.updateState({separateAnswerSheetsFromQuestions: e.currentTarget.checked});
	},
	updateEmail: function(e) {
		this.updateState({email: e.currentTarget.value});
	},
	done: function(e) {
		var totalPoints = 0;
		this.state.items.forEach(function(item) {
			if (item.points) {
				totalPoints += item.points;
			}
		}); 
		if (totalPoints == 0) {
			alert("Add some questions first! (and make sure at least some of them have a point value.");
			return false;
		}
		mixpanel.track("Create quiz");
		e.preventDefault();
		var form = document.createElement('form');
		var field = document.createElement('input');
		field.name = 'form_json';
		field.value = JSON.stringify(this.state);
		form.appendChild(field);
		form.method = 'POST';
		form.action = '/submit';

		// ie requires that forms be added to the DOM:
		document.body.appendChild(form);
		form.style.display = 'none';
		
		form.submit();
	},
	insertItem: function(item) {
		item = update(item, {$merge: {id: generateUniqueId()}});
		var updates = {items: {$push: [item]}};
		this.setState(update(this.state, updates))
	},
	deleteItem: function(item) {
		var index = this.indexOfItemWithId(item.id);
		var items = this.state.items.slice();
		items.splice(index, 1);
		this.setState(update(this.state, {$merge: {items: items}}));
	},
	getInitialState: function() {
		var initial = {
			items: [
				{type: "title", text: "Quiz Title", notDraggable: true},
				{type: "name-field", displayHeader: false, notDraggable: true},
				/*{type: "multiple-choice", options: 4, correct: 0, description: "Example question prompt (optional)", points: 1},
				{type: "true-false", correct: false, description: "A true or false question:", points: 2},
				{type: "free-response", height: 4, description: "A free-response question:", points: 3}*/
			]
		};
		var existingJsonContainer = document.getElementById("form_json");
		if (existingJsonContainer) {
			initial.items = JSON.parse(existingJsonContainer.textContent).items;
		}
		initial.items.forEach(function(item) {
			item.id = generateUniqueId();
		})
		return initial;
	},
	indexOfItemWithId: function(id) {
		for (var i=0; i<this.state.items.length; i++) {
			if (this.state.items[i].id == id) {
				return i;
			}
		}
		return -1;
	},
	// dragging:
	dragStart: function(e) {
		this.dragged = e.currentTarget;
		e.dataTransfer.effectAllowed = 'move';
		e.dataTransfer.setData("text/html", this.dragged);
		this.dragPlaceholder = document.createElement('div');
		this.dragPlaceholder.className = 'drag-placeholder';
		this.dragPlaceholder.style.height = this.dragged.clientHeight;
		this.draggingFromIndex = this.indexOfItemWithId(this.dragged.dataset.id);
	},
	dragOver: function(e) {
		e.preventDefault();
		
		if (e.currentTarget.className == 'drag-placeholder') return;
				
		this.over = e.currentTarget;
		this.dragged.style.display = 'none';
		
		var height = this.over.offsetHeight / 2;
		var parent = e.currentTarget.parentNode;
		if(e.clientY > this.over.getBoundingClientRect().top + this.over.offsetHeight/2) {
		  parent.insertBefore(this.dragPlaceholder, e.currentTarget.nextElementSibling);
			this.dropIndex = this.indexOfItemWithId(this.over.dataset.id)+1;
		}
		else  {
		  parent.insertBefore(this.dragPlaceholder, e.currentTarget);
			this.dropIndex = this.indexOfItemWithId(this.over.dataset.id);
		}
	},
	dragEnd: function(e) {
		this.dragged.style.display = 'block';
		this.dragPlaceholder.parentNode.removeChild(this.dragPlaceholder);
		this.dragPlaceholder = undefined;
		
		var fromIndex = this.draggingFromIndex;
		var item = this.state.items[fromIndex];
		var toIndex = (fromIndex < this.dropIndex)? this.dropIndex-1 : this.dropIndex;
		var items = this.state.items.slice();
		items.splice(fromIndex, 1);
		items.splice(toIndex, 0, item);
		this.setState(update(this.state, {$merge: {items: items}}));
		
		e.preventDefault();
	},
	drop: function(e) {
		e.preventDefault();
	}
})

var FormItem = React.createClass({
	render: function() {
		var self = this;
		var onDescriptionChange = function(desc) {
			self.props.onItemChange({description: desc});
		}
		var header = "";
		if (this.shouldDisplayHeader()) {
			var descriptionField = function() {
				if (shouldDisplayDescriptionForItem(self.props.item)) {
					if (self.props.uneditableDescription) {
						return <div className='description' value={self.props.item.description}/>
					} else {
						return <ContentEditable className='description' value={self.props.item.description} onChange={onDescriptionChange}/>
					}
				} else {
					return <div className='description'></div>
				}
			}
			var pointValueField = function() {
				if (itemCanHavePointValue(self.props.item)) {
					return <div className='point-value'>
								Point value: <ContentEditable onChange={self.changePointValue} value={self.props.item.points} singleLine={true} selectAllOnFocus={true}/>
							</div>
				} else {
					return <span></span>
				}
			}
			var questionNumber = function() {
				if (shouldCountItemAsQuestion(self.props.item)) {
					return <div className='number'>{self.props.index != undefined ? self.props.index+1 : undefined}</div>
				} else {
					return <div></div>
				}
			}
			header = <div className='item-header'>
									<div className='controls'>
										{pointValueField()}
										<div className='icon-drag'></div>
										<div className='icon-close' onClick={self.deleteThis}></div>
									</div>
									{questionNumber() }
									{descriptionField() }
							 </div>
		}
		return <div data-form-item-type={ this.props.item.type } onClick={this.props.onClick} onDragStart={this.props.onDragStart} onDragEnd={this.props.onDragEnd} onDragOver={this.props.onDragOver} onDrop={this.props.onDrop} draggable={!this.props.item.notDraggable} data-id={this.props.item.id}>
						{header}
						<div className='label'>{ this.props.item.label }</div>
						<div className='item-content'>{ this.renderInternals() }</div>
					 </div>
	},
	deleteThis: function() {
		this.props.onDelete(this.props.item);
	},
	changePointValue: function(value) {
		if (parseFloat(value) !== NaN && parseFloat(value) >= 0) {
			this.props.onItemChange({points: parseFloat(value)});
		}
	},
	shouldDisplayHeader: function() {
		return shouldDisplayHeaderForItem(this.props.item);
	},
	renderInternals: function() {
		var self = this;
		var type = this.props.item.type;
		if (type == 'title') {
			var onTextChange = function(text) {
				self.props.onItemChange({ text: text });
			}
			return <ContentEditable value={this.props.item.text} onChange={onTextChange}/>
		} else if (type == 'true-false') {
			var selectedIndexChanged = function(index) {
				self.props.onItemChange({ correct: index==0 });
			}
			var segments = ["True", "False"];
			return <SegmentedControl selectedIndex={this.props.item.correct? 0 : 1} segments={segments} onSelectedIndexChange={selectedIndexChanged}/>
		} else if (type == 'multiple-choice') {
			var selectedIndexChanged = function(index) {
				self.props.onItemChange({ correct: index });
			}
			var segments = [];
			for (var i=0; i<self.props.item.options; i++) {
				segments.push("ABCDEFGH"[i]);
			}
			return <SegmentedControl selectedIndex={self.props.item.correct} segments={segments} onSelectedIndexChange={selectedIndexChanged}/>
		} else if (type == 'free-response') {
			var style = {height: self.props.item.height+'em'};
			return <div>
								<div className='freeResponse' style={style}></div>
								<p className='hint'>We'll take a picture of what's written in this free response question, but you'll have to enter a grade for it yourself.'</p>
						 </div>
							
		} else if (type == 'name-field') {
			var style = {height: "2em"};
			return <div>
								Student Name:
								<div className='freeResponse' style={style}></div>
							</div>
		} else if (type == 'section') {
			var onTextChange = function(text) {
				self.props.onItemChange({ text: text });
			}
			return <div>
						<ContentEditable value={this.props.item.text} onChange={onTextChange} />
					</div>
		}
		return "Nothing here!?!?"
	}
})

var SegmentedControl = React.createClass({
	render: function() {
		var self = this;
		var selectedComponent = function(e) {
			e.stopPropagation();
			self.props.onSelectedIndexChange(parseInt(e.target.getAttribute('data-segment-index')));
		}
		function renderSegment(segment, index) {
			var className = self.props.selectedIndex == index ? 'selected' : '';
			return <div onClick={selectedComponent} className={className} data-segment-index={index} key={index}>{segment}</div> 
		}
		return <div className='segmentedControl'>{this.props.segments.map(renderSegment)}</div>
	}
})

var ContentEditable = React.createClass({
	render: function() {
		var self = this;
		var changed = function(e) {
			if (getInnerText(e.currentTarget) != self.props.value) {
				self.props.onChange(getInnerText(e.currentTarget));
			}
		}
		var node = <div contentEditable={true} onFocus={this.focus} onBlur={changed} onInput={changed} onKeyDown={this.keyDown} className={this.props.className} onMouseEnter={this.turnOffParentContentEditable} onMouseLeave={this.turnOnParentContentEditable}></div>
		return node;
	},
	shouldComponentUpdate: function(nextProps) {
		return nextProps.value !== getInnerText(this.getDOMNode());
	},
	componentDidMount: function() {
		if (this.props.value != undefined)
			setInnerText(this.getDOMNode(), this.props.value);
	},
	componentDidUpdate: function() {
		if (this.props.value != undefined)
			setInnerText(this.getDOMNode(), this.props.value);
	},
	keyDown: function(e) {
		if (this.props.singleLine) {
			if (e.keyCode == 13) {
				e.preventDefault();
				e.currentTarget.blur();
			}
		}
	},
	focus: function(e) {
		if (this.props.selectAllOnFocus) {
			setTimeout(function() {
				document.execCommand('selectAll', false, null);
			})
		}
	},
	// HACK: these are workarounds for Safari, in which contentEditables inside [draggable]s can't focus.
	turnOffParentContentEditable: function(e) {
		var parent = e.currentTarget;
		while (parent) {
			if (parent.hasAttribute('draggable')) {
				parent.setAttribute('draggable', 'suspended');
				break;
			}
			parent = parent.parentNode;
		}
	},
	turnOnParentContentEditable: function(e) {
		var parent = e.currentTarget;
		while (parent) {
			if (parent.hasAttribute('draggable')) {
				parent.setAttribute('draggable', 'true');
				break;
			}
			parent = parent.parentNode;
		}
	}
})

var NewItemPicker = React.createClass({
	render: function() {
		var self = this;
		var templates = [
			{type: "multiple-choice", options: 4, correct: 2, id: 'abcd', label: "Multiple choice question", points: 1},
			{type: "multiple-choice", options: 5, correct: 1, id: 'abcde', label: "Multiple choice (5 options)", points: 1},
			{type: "true-false", correct: true, id: 'tf', label: "True or false question", points: 1},
			{type: "section", label: "Section header", text: "", id: 'hd'},
			{type: "free-response", height: 4, id: 'fr', label: "Free response", points: 1}
		];
		var renderedItems = templates.map(function(item) {
			var onChange = function(changes) {
				var newItem = update(item, {$merge: changes});
				self.props.onInsertItem(newItem);
			}
			var onClick = function(e) {
				self.props.onInsertItem(item);
			}
			return <FormItem item={item} onItemChange={onChange} onClick={onClick} key={item.id} data-id={item.id} uneditableDescription/>
		});
		return <div className='newItemPicker'>
							<h6>{self.props.hasItems ? "Add more questions" : "Add some questions"}</h6>
							{renderedItems}
					 </div>
	}
})

