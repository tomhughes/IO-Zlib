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

ok(1, $file = IO::Zlib->new($name, "wb"));
ok(2, $file->print($hello));
ok(3, $file->close());

ok(4, $file = IO::Zlib->new($name, "rb"));
ok(5, !$file->eof());
ok(6, $file->read($uncomp, 1024) == length($hello));
ok(7, $file->eof());
ok(8, $file->close());

unlink($name);

ok(9, $hello eq $uncomp);
