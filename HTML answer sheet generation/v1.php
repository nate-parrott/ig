<?php
$sheetID = 1;
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
				margin: 50px;
				border: 20px solid black;
				width: 600px;
				height: 800px;
				overflow: hidden;
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
			#name-container > span {
				text-transform: uppercase;
				font-weight: bold;
			}
			#name-container > div {
				margin-top: 5px;
				width: 100%;
				height: 50px;
				border: 1px solid black;
			}
			#questions {
				-webkit-column-count: 2;
				-moz-column-count: 2;
				padding-left: 0px;
			}
			.question {
				list-style-type: none;
				padding-top: 7px;
				padding-bottom: 7px;
				text-align: center;
			}
			.question > * {
				vertical-align: middle;
			}
			.question > span {
				display: inline-block;
				font-weight: bold;
				margin-right: 10px;
				width: 2em;
			}
			.question .options {
				display: inline-table;
				border-collapse: collapse;
				padding-left: 0px;
			}
			.question .options li {
				border: 2px solid #ccc;
				list-style-type: none;
				display: table-cell;
				width: 30px;
				height: 30px;
				vertical-align: middle;
				text-align: center;
				color: gray;
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
			#logo {
				float: right;
			}
		</style>
	</head>
	<body>
		<div id='border'>
			<div id='position-container'>
				<div id='quiz-contents'>
					<div id='name-container'>
						<span>Name</span>
						<div class='imageField' name='name'></div>
					</div>
					<ol id='questions'>
						<?php
						for ($i=0; $i<20; $i++) {
							$i1 = $i+1;
							echo "<li class='question'>";
								echo "<span>$i1</span>";
								echo "<ul class='options'>";
									for ($o=0; $o<4; $o++) {
										$ltr = substr("ABCDEFGHIJKLMN", $o, 1);
										echo "<li>$ltr</li>";
									}
								echo "</ul>";
							echo "</li>";
						}
						?>
					</ol>
					<img id='logo' src='logo.png' style='width: 150px; height: 50px'/>
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
