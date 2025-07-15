#!/usr/bin/env pwsh

#========================================================================
# TECH+記事のCMSで不要な要素を非表示に変更する
#========================================================================
Invoke-SeJavascript -Script '
var targets = [
	"/html/body/div[1]/div[1]/section[1]",
	"/html/body/div[1]/div[1]/section[2]/div[1]/div",
	"//*[@id=\"head_link_1\"]/div[1]",
	"//*[@id=\"head_link_2\"]/div[1]",
	"//*[@id=\"head_link_2\"]/div[2]/div[1]",
	"//*[@id=\"head_link_2\"]/div[2]/div[2]",
	"//*[@id=\"head_link_2\"]/div[2]/div[3]",
	"//*[@id=\"head_link_2\"]/div[2]/div[4]",
	"//*[@id=\"head_link_2\"]/div[2]/div[5]",
	"//*[@id=\"head_link_2\"]/div[2]/div[6]",
	"//*[@id=\"head_link_2\"]/div[2]/div[7]",
	"//*[@id=\"head_link_2\"]/div[2]/div[8]",
	"//*[@id=\"head_link_2\"]/div[2]/div[9]",
	"//*[@id=\"head_link_2\"]/div[2]/div[10]",
	"//*[@id=\"head_link_2\"]/div[2]/div[11]",
	"//*[@id=\"head_link_2\"]/div[2]/div[12]",
	"//*[@id=\"head_link_2\"]/div[2]/div[16]",
	"//*[@id=\"head_link_2\"]/div[2]/div[18]",
	"//*[@id=\"head_link_2\"]/div[2]/div[19]",
	"//*[@id=\"head_link_2\"]/div[2]/div[20]",
	"//*[@id=\"head_link_2\"]/div[2]/div[21]",
	"//*[@id=\"head_link_2\"]/div[2]/div[22]",
	"//*[@id=\"head_link_2\"]/div[2]/div[23]",
	"//*[@id=\"head_link_2\"]/div[2]/div[24]",
	"//*[@id=\"head_link_2\"]/div[2]/div[25]",
	"//*[@id=\"head_link_2\"]/div[2]/div[26]",
	"//*[@id=\"head_link_2\"]/div[2]/div[27]",
	"//*[@id=\"head_link_2\"]/div[2]/div[28]",
	"//*[@id=\"head_link_2\"]/div[2]/div[29]",
	"//*[@id=\"head_link_2\"]/div[2]/div[30]",
	"//*[@id=\"head_link_2\"]/div[2]/div[32]",
	"//*[@id=\"head_link_2\"]/div[2]/div[33]",
	"//*[@id=\"head_link_2\"]/div[2]/div[34]",
	"//*[@id=\"head_link_3\"]/div[1]",
	"//*[@id=\"head_link_3\"]/div[2]/div[1]",
	"//*[@id=\"head_link_3\"]/div[2]/div[2]/h4",
	"//*[@id=\"head_link_3\"]/div[2]/div[2]/div[1]",
	"//*[@id=\"head_link_3\"]/div[2]/div[3]/h4",
	"//*[@id=\"head_link_3\"]/div[2]/div[3]/div[1]",
	"//*[@id=\"head_link_3\"]/div[2]/div[4]",
	"//*[@id=\"head_link_3\"]/div[2]/div[5]",
	"//*[@id=\"head_link_5\"]",
	"//*[@id=\"head_link_yahoo\"]",
	"//*[@id=\"head_link_6\"]",
	"//*[@id=\"head_link_7\"]",
	"//*[@id=\"head_link_seo_howto\"]",
	"//*[@id=\"head_link_seo_video\"]"
];

targets.forEach((xpath, i) => {
	var eles = document.evaluate(
		xpath, 
		document,
		null,
		XPathResult.ORDERED_NODE_ITERATOR_TYPE,
		null);
	var e = eles.iterateNext();
	if (null != e) {
		e.setAttribute("style", "display:none");
	}
});
'
