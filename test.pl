# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Crypt::Beowulf;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
$string = "This is an encryption test.\n";
for ($i=32; $i<=126; $i++) {
        $string .= chr($i);
}
$length = length($string);
$passphrase = "abcdefg";

print ("Original text: $string\n");
print ("Passphrase:  $passphrase\n\n");
$string =~ s/\r//g;

$cipher = BeoEncrypt( $string, $passphrase );

print ("Phrase: $phrase\n");
print ("Encrypted text: $cipher\n");

$plain = BeoDecrypt( $cipher, $passphrase );

print ("\nPhrase: $phrase\n");
print ("Decrypted text: $plain\n\n");

@plain = split(//, $plain);
@string = split(//,$string);

for ($i=0; $i<=$#string; $i++) {
        if ($string[$i] ne $plain[$i]) {
                print ("Mismatch:  :$string[$i]: :$plain[$i]:\n");
                next;
        }
}

