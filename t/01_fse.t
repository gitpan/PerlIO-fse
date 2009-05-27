#!perl
use strict;
use warnings;
use Test::More;

use PerlIO::fse;
use constant FSE => (PerlIO::fse->get_fse);

BEGIN{
	if(FSE ne 'cp932'){
		plan skip_all => 'PerlIO FSE tests are only for CP932 environment';
		exit;
	}

	plan tests => 9;
}

use FindBin qw($Bin);
use File::Spec;
use utf8;

diag 'fse = ', FSE;

my $basename = 'ファイルシステムエンコーディング.txt';
my $utf8     = File::Spec->catfile($Bin, 'util', $basename);
my $non_utf8 = File::Spec->catfile($Bin, 'util', 'foo.txt');
my $fse      = FSE;

ok open(my $io, '>:fse', $utf8), 'open for writing';
ok(Encode->VERSION, 'Encode.pm loaded');

my $fsnative = Encode::encode(FSE, $utf8);

ok -e $fsnative, 'encoded file created';

ok open($io, '<:fse', $utf8), 'open for reading';

ok open($io, "<:fse($fse)", $utf8), 'open for reading (explicit)';

ok open($io, '<:fse', $non_utf8), 'open non-utf8 file';
is scalar(<$io>), 'foo.txt';
close $io;

eval{
	PerlIO::fse->set_fse('hogehoge');
	open($io, '<:fse', $utf8);
};
ok $@, 'invalid encoding';

ok unlink($fsnative), '(cleanup)';
