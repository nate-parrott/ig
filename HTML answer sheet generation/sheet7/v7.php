<?php
$sheetID = 7;
?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8"/>
		<script src='jquery.js'></script>
		<script>
			function position(el) {
				var quizOffset = $('#position-container').offset();
				var quizWidth = $('#position-container').width();
				var quizHeight = $('#position-container').height();
				
				return {
					x: ($(el).offset().left-quizOffset.left)/quizWidth,
					y: ($(el).offset().top-quizOffset.top)/quizHeight,
					w: $(el).width()/quizWidth,
					h: $(el).height()/quizHeight
				}
			}
			function extractInfo() {
				var info = {
					id: $('#barcode').attr('value'), 
					questions: [], 
					imageFields: []
					};
				$('.question').each(function(i, q) {
					info.questions.push({
						numOptions: $(q).find('.options>li').length,
						position: position($(q).find('.options'))
					});
				})
				$('.imageField').each(function(i, f) {
					info.imageFields.push({
						name: $(f).attr('name'),
						position: position(f)
					});
				})
				$("<textarea></textarea").css({position: 'absolute', top: 0, left: 0, width: 500, height: 500}).appendTo(document.body).get(0).value=JSON.stringify(info);
			}
		</script>
		<style>
			body {
				font-family: sans-serif;
				font-size: large;
			}
			#border {
				border: 40px solid black;
				width: 700px;
				height: 580px;
				overflow: hidden;
				margin-top: 100px;
			}
			#position-container {
				position: relative;
				width: 100%;
				height: 100%;
			}
			#quiz-contents {
				padding: 50px;
				padding-bottom: 50px;
			}
			
			#header {
				display: flex;
				flex-direction: row;
				align-items: center;
			}
			#header .imageField {
				flex-grow: 1;
				border: 1px dotted black;
				border-bottom: 1px solid black;
				align-self: stretch;
				margin-left: 10px;
				margin-right: 10px;
			}
			#header > span {
				text-transform: uppercase;
				font-size: small;
				font-weight: bold;
			}
			#header #logo {
				align-self: center;
			}
			
			#questions {
				-webkit-column-count: 3;
				-moz-column-count: 3;
				padding-left: 0px;
			}
			.question {
				list-style-type: none;
				padding-top: 6px;
				padding-bottom: 6px;
				text-align: center;
			}
			.question > * {
				vertical-align: middle;
			}
			.question > span {
				display: inline-block;
				font-weight: bold;
				margin-right: 4px;
				width: 2em;
			}
			.question .options {
				display: inline-table;
				border-collapse: collapse;
				padding-left: 0px;
			}
			.question .options li {
				border: 1px solid #777;
				list-style-type: none;
				display: table-cell;
				width: 27px;
				height: 27px;
				vertical-align: middle;
				padding-top: 3px;
				text-align: center;
				color: #aaa;
				font-weight: bold;
			}
			#barcode {
				position: absolute;
				left: 5%;
				width: 90%;
				bottom: 5%;
				height: 5%;
			}
			#barcode > div {
				display: inline-block;
				width: 10%;
				height: 100%;
				position: relative;
			}
			#barcode > div > div {
				width: 100%;
				height: 50%;
			}
			#barcode > div > div:first-child {
				top: 0%;
			}
			#barcode > div > div:last-child {
				top: 50%;
			}
			#barcode > div[value=off] > div:first-child,
			#barcode > div[value=on] > div:last-child {
				background-color: black;
			}
			#info {
				font-size: small;
				color: gray;
				text-align: center;
			}
		</style>
	</head>
	<body>
		<div id='border'>
			<div id='position-container'>
				<div id='quiz-contents'>
					<div id='header'>
						<span>Name</span>
						<div class='imageField' name='name'></div>
						<img id='logo' src='logo.png' style='width: 132px; height: 38px'/>
					</div>
					<ol id='questions'>
						<?php
						for ($i=0; $i<24; $i++) {
							$i1 = $i+1;
							echo "<li class='question'>";
								echo "<span>$i1</span>";
								echo "<ul class='options'>";
									for ($o=0; $o<5; $o++) {
										$ltr = substr("ABCDEFGHIJKLMN", $o, 1);
										echo "<li>$ltr</li>";
									}
								echo "</ul>";
							echo "</li>";
						}
						?>
					</ol>
					<div id='info'>
						Fill in boxes completely • Don't write outside the boxes • Don't fold • v<?php echo $sheetID;?> • <strong>insta-grade.appspot.com</strong>
					</div>
				</div>
				<div id='barcode' value='<?php echo $sheetID;?>'>
					<?php
					# sheetID is stored in the barcode as a little-endian binary number:
					$idBinary = strrev(base_convert($sheetID, 10, 2));
					for ($i=0; $i<10; $i++) {
						$val = ($i < strlen($idBinary) && $idBinary[$i]=="1")? "on" : "off";
						echo "<div value='$val'>
							<div></div> <div></div>
						</div>";
					}
					?>
				</div>
			</div>
		</div>
	</body>
</html>
