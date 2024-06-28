#!/usr/bin/perl

$filename = $ARGV[0] or die "nie podales pliku\n";
open($fh, '<', $filename); 
binmode($fh, ':encoding(utf8)');

%students;
@dates;
$current_date = '';

while ($line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;

    if ($line =~ /^(\d+\.\w+)/) {
        $current_date = $1;
        push @dates, $current_date;
    } elsif ($current_date && $line =~ /(.+):\s*(\+*)/) {
        ($student, $pluses) = ($1, $2);
        $score = length $pluses;
        $students{$student}{$current_date} = $score;
    }
}
close($fh);

$html_filename = "$filename.html";
open($html, '>', $html_filename);
binmode($html, ':encoding(utf8)');

print $html "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"UTF-8\">\n<title>aktywnosc studentow</title>\n</head>\n<body>\n";
print $html "<table border=\"1\">\n<tr><th>imie i nazwisko</th>";

foreach $date (@dates) {
    print $html "<th>$date</th>";
}

print $html "<th>suma punktow</th></tr>\n";

foreach $student (sort keys %students) {
    print $html "<tr><td>$student</td>";
    $total_points = 0;
    
    foreach $date (@dates) {
        $points = $students{$student}{$date};
        $total_points += $points;
        print $html "<td>$points</td>";
    }
    
    print $html "<td>$total_points</td></tr>\n";
}

print $html "</table>\n</body>\n</html>";
close($html);

print "HTML-plik '$html_filename' zostal utworzony\n";
