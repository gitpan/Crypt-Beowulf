#!/usr/bin/perl

##
## Crypt::Beowulf
##
## Copyright (c) 2000, Kurt Kincaid (ceo@neurogames.com)
## This code is free software; you can redistribute it and/or modify
## it under the same terms as Perl itself.
##

package Crypt::Beowulf;

require Exporter;
$VERSION = '0.2.10';

@ISA = qw(Exporter);
use vars qw($VERSION @EXPORT_OK);
@EXPORT = qw(BeoEncrypt BeoDecrypt BeoCrypt);
@EXPORT_OK = qw(@chars $multFactor $VERSION);

sub Phrase { 
	# Private sub-routine, called only by BeoEncrypt, BeoDecrypt, & BeoCrypt
	my $phrase = shift;
	my $i;
	while (length($phrase) < 10) {
		$phrase .= "x";
	}
	$phrase =~ s/./ord($&)/eg;
	$phrase = sprintf("%.0f", ($phrase ** 0.4));
	srand $phrase;
	my $i;
	undef @chars;
	for ($i=33; $i<=126; $i++) {
	        push (@chars, chr($i));
	}
	unshift(@chars, chr(32));
	for ($i=0; $i<=$#chars; $i++) {
		$plain{$chars[$i]} = $i;
	}
	$holder = chr(127);
}

sub BeoEncrypt {
	( $text, $passphrase ) = @_;
	$text =~ s/\r//g;
	$text =~ s/\t/    /g;
	Phrase($passphrase);

	$multFactor = 1;

	$text =~ s/\n/$holder/g;
	$text =~ s/./Permute($&)/eg;
	return $text;
}

sub BeoDecrypt {
	( $text, $passphrase ) = @_;
	Phrase($passphrase);

	$multFactor = -1;

	$text =~ s/[\r\n]//g;
	$text =~ s/./Permute($&)/eg;
	$text =~ s/$holder/\n/g;
	return $text;
}

sub BeoCrypt {
	my ( $text, $passphrase, $mode ) = @_;
	Phrase($passphrase);
	if ($mode eq "e") {
		$multFactor = 1;
		$text =~ s/\n/$holder/g;
	} elsif ($mode eq "d") {
		$multFactor = -1;
		$text =~ s/[\r\n]//g;
		$text =~ s/$holder/\n/g;
	}
	$text =~ s/./Permute($&)/eg;
	return $text;
}

sub Permute {
	my $character = shift;
	if ($character eq $holder) {
		return $character;
	}
	my $pos = $plain{$character};
	my $pos2 = int(rand 95);
	my $shift = $pos + $multFactor * $pos2;
	if ($shift > 94) {
		$shift -= 95;
	} elsif ($shift < 0) {    
		$shift += 95;
	}
	$character = $chars[$shift];
	return $character;
}

1;

=head1 NAME

Crypt::Beowulf - Beowulf encryption

=head1 SYNOPSIS

  use Crypt::Beowulf;

  my $cipher = BeoEncrypt( $text, $passphrase );
  my $plain = BeoDecrypt( $text, $passphrase );
  
  # Or you can do the encryption and decryption with
  # the same method, as follows:
  
  my $encrypted = BeoCrypt( $text, $passphrase, "e");
  my $decrypted = BeoCrypt( $text, $passphrase, "d");

=head1 NOTICE

Although I have used this module, personally, a great deal, it has not undergone extensive public testing.  As such, it should still be considered to be beta software.  If anyone encounters a problem, bug, or loophole, please email me at ceo@neurogames.com.  And I'm open to any suggestions that anyone may have to improved either the module or the algorithm itself.

=head1 DESCRIPTION

I originally designed this system in response to a need for an encryption scheme for Neurogames that encrypted text using a fairly standard character set, as opposed to the various and sundry control-characters and meta-characters that end up being part of the ciphertext when using extent encryption modules, such as Crypt::TripleDES and Crypt::GOST.  Personally, I ran into several cross-platform problems with the control characters being mis-interpreted by one OS or another, or by text-editing software. In theory at least, the fairly standard ASCII set used by Crypt::Beowulf should remedy that matter.  Another advantage is that it is substantially faster than encrypting with TripleDES or GOST.  Based on benchmarks encrypting the same text, Crypt::Beowulf is between 3 and 10 times faster than either Crypt::GOST or Crypt::TripleDES.  The code is based on 95-element permutation (95!, or approx. 1.033 * 10^148 possible combinations). It should hold up fairly well against brute-force deciphering, though in theory, there could be some sort of shortcut to cracking the code, of which I'm unaware.

Please note that in the event that a passphrase is less than 10 characters long, "x" will be padded to the end to reach a minimum of 10 characters. In theory, there is no upper limit to the length of the passphrase.  In addition, for the particularly security-conscious, this encryption method supports multiple encryption, so after encrypting your text, you can encrypt the cipher text as many times as you wish (personally, I've never tested this over more than approx. 10 passes), and decryption of a like number of times will be necessary to get the plain text.  If one were so inclined, the passphrase could be changed for each pass.  If you do this, remember to decrypt using the multiple passphrases in reverse order.

=head1 METHODS 

=over 4

=item B<BeoEncrypt>( $plaintext, $passphrase );

Encrypts $plaintext using $passphrase to initialize the randomization.

=item B<BeoDecrypt>( $cyphertext, $passphrase );

Same as BeoEncrypt, only in the other direction.

=item B<BeoCrypt>( $text, $passphrase, $mode );

Encryption and decryption included in one nice, neat little package. If we are
encrypting, pass a value of "e" for $mode, if we're decrypting, pass a value
of "d".

=back 

=head1 LIMITATIONS

Due to the nature of the of the ordered code stream, this system is really 
only designed to be used on text files, or to a lesser degree, word processing 
documents.  The program doesn't like control-characters or meta-characters,  and subsequently ignores them.  For example, graphic files encrypted with Beowulf will not decrypt correctly.

=head1 AUTHOR

Kurt Kincaid, ceo@neurogames.com

=cut

