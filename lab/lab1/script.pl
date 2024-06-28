#!/usr/bin/perl -w

if("XYZTabcooooooooabcefff" =~ /.*abc+/ ) {
	printf($&);
}
 else {
	printf("ne-aboba");
}
