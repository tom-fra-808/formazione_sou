BEGIN {
	FS = ","
}
{
	for (i = 1; i <= NF; i++){
		if ($i == "banana") {
			print $3
			break
		}
	}
}