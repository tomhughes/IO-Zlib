use IO::Zlib;

sub ok
{
    my ($no, $ok) = @_ ;

    #++ $total ;
    #++ $totalBad unless $ok ;

    print "ok $no\n" if $ok ;
    print "not ok $no\n" unless $ok ;
}

$name="test.gz";

print "1..9\n";

$hello = <<EOM ;
hello world
this is a test
EOM

ok(1, tie *OUT, "IO::Zlib", $name, "wb");
ok(2, print OUT $hello);
ok(3, untie *OUT);

ok(4, tie *IN, "IO::Zlib", $name, "rb");
ok(5, !tied(*IN)->eof());
ok(6, read(IN, $uncomp, 1024) == length($hello));
ok(7, tied(*IN)->eof());
ok(8, untie *IN);

unlink($name);

ok(9, $hello eq $uncomp);
