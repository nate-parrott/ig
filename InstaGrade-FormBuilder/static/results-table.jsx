/** @jsx React.DOM */

function average(nums) {
	var s = 0;
	nums.forEach(function(n) {s += n})
	return s / nums.length;
}

function sparkline(nums, buckets) {
	var items = [];
	if (nums.length) {
		var sorted = nums.slice(0);
		sorted.sort(function(a,b){return a-b});
		var bucketed = [];
		for (var bucket=0; bucket<buckets; bucket++) {
			bucketed.push(sorted.slice(Math.floor(nums.length/buckets*bucket), Math.ceil(nums.length/buckets*(bucket+1))));
		}
		var max = sorted[sorted.length-1];
		var items = bucketed.map(function(b){
			var style = {height: (average(b)/max*100)+"%"};
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
			return <h5>No results yet</h5>
		} else {
			document.body.className = 'hasResults';
			var tabs = [
				{name: "Students", render: function() {
					return <Instances instances={self.props.instances}/>
				}},
				{name: "Questions", render: function() {
					return <Questions instances={self.props.instances}/>
				}},
				/*{name: "Download Results", render: function() {
					return <div>Download</div>
				}}*/
			];
			return <TabView tabs={tabs} instances={self.props.instances}/>
		}
	}
})

function calculateStats(instances) {
	var scoreSum = average(instances.map(function(i){return i.points}));
	return {
		maxPoints: instances[0].maxPoints,
		averagePoints: scoreSum/instances.length,
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
	render: function() {
		var listItems = this.props.instances.map(function(instance) {
			var exampleImage = 'https://storage.googleapis.com/instagradeformbuilder.appspot.com/0c9850cf436441b6adab6444d26e0bd2';
			return <tr key={instance.id}>
						<td><img className='nameImage' src={nameImageUrl}/></td>
						<td>{instance.points} / {instance.maxPoints}</td>
						<td>{Math.round(instance.points/instance.maxPoints*100)}%</td>
				   </tr>
		})
		return <table className='instances'>{listItems}</table>
	}
})

var Questions = React.createClass({
	render: function() {
		var self = this;
		var questionObjects = [];
		var questionObjectsForVisibleIndex = {};
		self.props.instances.forEach(function(instance) {
			instance.items.forEach(function(questionItem) {
				if (questionItem.visibleIndex != undefined) {
					var questionObj = questionObjectsForVisibleIndex[questionItem.visibleIndex];
					if (!questionObj) {
						questionObj = {scores: [], nameImages: [], text: questionItem.description, points: questionItem.points, index: questionItem.visibleIndex};
						questionObjectsForVisibleIndex[questionItem.visibleIndex] = questionObj;
						questionObjects.push(questionObj);
					}
					questionObj.scores.push(questionItem.pointsEarned);
					questionObj.nameImages.push(instance.nameImageUrl);;
				}
			})
		})
		var questionLIs = questionObjects.map(function(q) {
			var avg = Math.round(average(q.scores)*4)/4;
			return <tr key={q.index}>
						<td className='questionIndex'><strong>{q.index}</strong> <span class='questionText'>{q.text}</span></td>
						<td>Average points: <strong>{avg} out of {q.points}</strong></td>
						<td>{sparkline(q.scores,Math.min(20, q.scores.length))}</td>
					</tr>
		})
		return <table className='questions'>{questionLIs}</table>
	}
})

var instances = JSON.parse(document.getElementById('instances-json').innerText);
React.renderComponent(<ResultsTable instances={instances}/>, document.getElementById('results-table'));
