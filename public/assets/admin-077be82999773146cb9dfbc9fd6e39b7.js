
function showSection(id, sub){
	$('#section'+id).addClass('on');
	$('#subnav'+id).show();
	if (sub != '' && sub != null){
		$('#sub'+id+sub).addClass('on');
		console.log('#sub'+id+sub)
	}
}
;
