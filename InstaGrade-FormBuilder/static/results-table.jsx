/** @jsx React.DOM */

// http://localhost:13080/iCp0aD0qaPv0Jy1Mpa5cmrMNPGq3tUdY4mJZGKYcRnqhOk0_LiLU8puuGSIwo218KxP9gY5u9O-X650GREY3zyFaNNLjEEv3tSUOHRYSAZw=
// http://instagradeformbuilder.appspot.com/fx7kjJoYSJkxl8WLd3N7Lveqv4_XjHsflQHCmN94gMDp0E4t4ugoAPfJYIeVpAE04Pz_2lSHeQo-0PWSPnWPXBw59ywX0UI9mvZp10OdqOc=

function average(nums) {
	var s = 0;
	nums.forEach(function(n) {s += n})
	return s / nums.length;
}

function sparkline(nums, max, buckets) {
	var items = [];
	if (nums.length) {
		var sorted = nums.slice(0);
		sorted.sort(function(a,b){return a-b});
		var bucketed = [];
		for (var bucket=0; bucket<buckets; bucket++) {
			bucketed.push(sorted.slice(Math.floor(nums.length/buckets*bucket), Math.ceil(nums.length/buckets*(bucket+1))));
		}
		var items = bucketed.map(function(b){
			var baseHeight = 0.2;
			var style = {height: ((baseHeight+(1-baseHeight)*average(b)/max)*100)+"%"};
			return <div style={style}></div>
		});
	}
	return <div className='sparkline'>{items}</div>
}

var ResultsTable = React.createClass({
	render: function() {
		var self = this;
		if (self.props.instances.length == 0) {
			document.body.className = '';
			return <h5 style={{color: "gray"}}>No results yet</h5>
		} else {
			document.body.className = 'hasResults';
			var tabs = [
				{name: "Students", render: function() {
					return <Instances instances={self.props.instances}/>
				}},
				{name: "Questions", render: function() {
					return <Questions instances={self.props.instances}/>
				}},
				{name: "Download Results", render: function() {
					var excelUrl = '/' + self.props.secret + '/excel'
					return 	<div>
								<p><a href={excelUrl} className='cta'>Download results as Excel spreadsheet</a></p>
							</div>
				}}
			];
			return <TabView tabs={tabs} instances={self.props.instances}/>
		}
	}
})

function calculateStats(instances) {
	var scoreSum = average(instances.map(function(i){return i.points}));
	return {
		maxPoints: instances[0].maxPoints,
		averagePoints: scoreSum,
		count: instances.length
	};
}

var TabView = React.createClass({
	getInitialState: function() {
		return {selectedIndex: 0}
	},
	render: function() {
		var self = this;
		// make tabs:
		var i = 0;
		var selectedIndex = this.state.selectedIndex;
		var tabs = this.props.tabs.map(function(tab) {
			var index = i++;
			var classes = (index == selectedIndex) ? "selected" : "";
			var clicked = function() {
				self.setState({selectedIndex: index});
			}
			return <li onClick={clicked} className={classes} key={index}>{tab.name}</li>
		})
		// make summary:
		var stats = calculateStats(self.props.instances);
		var summary = <div className='summary'>Graded <strong>{stats.count}</strong>, average score <strong>{Math.round(stats.averagePoints*4)/4} / {stats.maxPoints}</strong></div>
		var printButton = <a href='javascript: window.print()' className='printButton'>Print</a>
		var tabControl = <ul className='tabControl'>{tabs}{printButton}{summary}</ul>
		var currentTabContent = this.props.tabs[this.state.selectedIndex].render();
		return <div className='tabView'>
				{tabControl}
				{currentTabContent}
			   </div>
	}
})

var Instances = React.createClass({
	getInitialState: function() {
		return {expandedIndex: -1};
	},
	render: function() {
		var self = this;
		var rows = [];
		var i = 0;
		this.props.instances.forEach(function(instance) {
			var exampleImage = 'https://storage.googleapis.com/instagradeformbuilder.appspot.com/0c9850cf436441b6adab6444d26e0bd2';
			var index = i++;
			var toggleExpanded = function() {
				if (index == self.state.expandedIndex) {
					self.setState({expandedIndex: -1});
				} else {
					self.setState({expandedIndex: index});
				}
			}
			var renderRow = function() {
				var className = index == self.state.expandedIndex ? "expanded" : "expandable";
				return <tr key={instance.id} onClick={toggleExpanded} className={className}>
						<td><img className='nameImage' src={instance.nameImageUrl}/></td>
						<td><strong>{instance.points}/{instance.maxPoints}</strong> points</td>
						<td>{Math.round(instance.points/instance.maxPoints*100)}%</td>
				   </tr>
			};
			var renderExpanded = function() {
				return <tr key={instance.id + "_expanded"}>
					<td colSpan="3">
						<IndividualResultTable instance={instance}/>
					</td>
				</tr>
			}
			rows.push(renderRow());
			if (self.state.expandedIndex == index) {
				rows.push(renderExpanded());
			}
		})
		return <table className='instances'><tbody>{rows}</tbody></table>
	}
})

var IndividualResultTable = React.createClass({
	render: function() {
		var self = this;
		var rows = self.props.instance.items.filter(function(item) {
			return item.visibleIndex != undefined;
		}).map(function(item) {
			return <tr>
						<td className='questionInfo'><strong>Question {item.visibleIndex}</strong> <span className='questionText'>{item.description}</span></td>
						<td>{item.gradingDescription}</td>
						<td className='score'>{item.pointsEarned}/{item.points}</td>
					</tr>
					
		})
		return <table className='individualResultTable'><tbody>{rows}</tbody></table>
	}
})

var Questions = React.createClass({
	getInitialState: function() {
		return {expandedIndex: -1};
	},
	render: function() {
		var self = this;
		var questionObjects = [];
		var questionObjectsForVisibleIndex = {};
		self.props.instances.forEach(function(instance) {
			instance.items.forEach(function(questionItem) {
				if (questionItem.visibleIndex != undefined) {
					var questionObj = questionObjectsForVisibleIndex[questionItem.visibleIndex];
					if (!questionObj) {
						questionObj = {scores: [], blanks: 0, nameImages: [], text: questionItem.description, points: questionItem.points, index: questionItem.visibleIndex};
						questionObjectsForVisibleIndex[questionItem.visibleIndex] = questionObj;
						questionObjects.push(questionObj);
					}
					questionObj.scores.push(questionItem.pointsEarned);
					questionObj.nameImages.push(instance.nameImageUrl);
					if (questionItem.response === null) {
						questionObj.blanks++;
					}
				}
			})
		})
		var i = 0;
		var rows = []
		questionObjects.forEach(function(q) {
			var index = i++;
			var className = index == self.state.expandedIndex ? "expanded" : "expandable";
			var toggleExpanded = function() {
				if (index == self.state.expandedIndex) {
					self.setState({expandedIndex: -1});
				} else {
					self.setState({expandedIndex: index});
				}
			}
			var avg = Math.round(average(q.scores)*4)/4;
			var row = <tr key={q.index} className={className} onClick={toggleExpanded}>
						<td className='questionInfo'><strong>Question {q.index}</strong> <span className='questionText'>{q.text}</span></td>
						<td>Average points: <strong>{avg} out of {q.points}</strong></td>
						<td><strong>{q.blanks}</strong> left blank</td>
						<td>{sparkline(q.scores,q.points,Math.min(20, q.scores.length))}</td>
					</tr>
			rows.push(row);
			if (index == self.state.expandedIndex) {
				var expanded =  <tr key={q.index + "_expanded"}>
									<td colSpan="4">
										<IndividualQuestionBreakdown index={q.index} instances={self.props.instances} />
									</td>
								</tr>
				rows.push(expanded);
			}
		})
		return <table className='questions'><tbody>{rows}</tbody></table>
	}
})

var IndividualQuestionBreakdown = React.createClass({
	render: function() {
		var self = this;
		var rows = self.props.instances.map(function(instance) {
			var row = "";
			instance.items.forEach(function(item) {
				if (item.visibleIndex === self.props.index) {
					row = <tr key={instance.id}>
							<td><img className='nameImage' src={instance.nameImageUrl}/></td>
							<td>{item.gradingDescription}</td>
						  </tr>
				}
			})
			return row;
		})
		return <table className='individualQuestionBreakdown'>{rows}</table>
	}
})

var instances = JSON.parse(document.getElementById('instances-json').textContent);
if (instances.length > 0) {
	mixpanel.track("ViewResults", {count: instances.length});
}
var secret = document.getElementById('secret').textContent;
React.renderComponent(<ResultsTable instances={instances} secret={secret} />, document.getElementById('results-table'));
