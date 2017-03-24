#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

=head1 NAME

fastQ_reduce_glob.pl

=head1 VERSION

0.1

=head1 DESCRIPTION

User selectable reduction of fastq read count

=head1 INPUT

current directory, all files ending .fastq 

=head1 OUTPUT

red_value.fastq files


=head1 OTHER REQUIREMENTS

bash shell

=head1 EXMAPLE USAGE

fastQ_reduce_glob.pl
followed by STDIN for proportion to reduce by

=head1 AUTHOR

Graham Taylor University of Melbourne
=cut

our $fastq ; #name of fastq file
our $header ; # first line of fastq set of 4 lines
our $sequence ; # second line of fastq set of 4 lines
our $third_line ; # third line of fastq
our $quality ; # fourth line of fastq set of 4 lines
our $count_in = 0; #read number
our $count_out = 0; # count number of reads output
our $output ; # file_name of reads output
our $reduce_rate ; 
our $reduction ; 
our $count ;
our @four_lines ;
our $numerator ;
our $modulo ;
my $seed ;
our @file_list ;
our $FASTQ ;
our $FASTQR ;

print "Reduces the number of fastq reads by a user selectable proprtion\.\n" ;
print "If you want to reduce two files exactly the same way, enter the same number\n" ;
print "to seed the pseudo-random number for both files\.\n\n";
#print "Enter a random seed number as an integer, or press return for a computer generated seed: \n";
#$seed = <STDIN>;
#chomp $seed ;
#if ($seed eq "")
#	{
#	srand(time|$$) ; #seed random number
#	} 	
#elsif ($seed=~m/\d+/)
#	{
#	srand($seed);
#	}
#else 
#	{
#	print "non-digit entered for random number seed\.\n";
#	exit ;
#	}
print "please type the proportion of reads to retain as integer: e.g. to retain 1/10 type 10\n";
$reduce_rate = <STDIN> ;
chomp $reduce_rate ;

# include decompress to add, requires fastq decompressed

@file_list = glob "*.fastq" ;
print "\n @file_list\n";

for $fastq (@file_list){
	next if($fastq=~ m/_red_/); #skip files already reduced containing chars "red_"
	print "$fastq\n";
	$fastq=~ s/\.gz//;
	reduce_count("$fastq") ;
	}
exit ;
#subroutines

=item *

reduce_count

    Title   : reduce_count
    Usage   : reduce_count
    Function: reduces number of fastq reads. 
    		  Since same random number is seeded for all files, same files numbers
    		  are selected up to eof.  Therefore F and R read pairs will match after
    		  count reduction.
    Returns : nothing
    Args    : fastq in current directory as @file_list
=cut

	
sub reduce_count
{
unless ( -e $fastq) 
	{
    print "File \"$fastq\" doesn\'t seem to exist!!\n";
    exit;
    }
# Can we open the file?
unless ( open($FASTQ,"<", $fastq) ) 
	{
    print "Cannot open file \"$fastq\"\n\n";
    exit;
	}

# open output file
$output=$fastq;
$output =~ s/\.fastq/_red_$reduce_rate\.fastq/ ; # append .fastq
open $FASTQR, ">", $output ;
$count_in = 0;
$count_out = 0;
$reduction = 0; 
#loop through fastq file
$count =1 ;
$numerator = 0 ; #this dice is now just a counter
while (<$FASTQ>) #collect arrays of four lines;
	{
		if ($count==1)
			{
			$header = $_ ;
			$count ++ ;
			$count_in ++;
			$numerator ++;
			}
		elsif ($count ==2)
			{
			$sequence  = $_ ;
			$count ++;
			}
		elsif ($count ==3)
			{
			$third_line = $_ ;
			$count ++ ;
			}
		elsif ($count == 4)
			{
			$quality = $_ ;
			$count = 1;

			if ($numerator % $reduce_rate == 0)
				{
				$count_out ++;
				$numerator = 0;
				chomp $header; chomp $sequence; chomp $third_line; chomp $quality;
				print $FASTQR "$header\n";
				print $FASTQR "$sequence\n" ;
				print $FASTQR "$third_line\n" ;
				print $FASTQR "$quality\n" ;
				}
			}
	}
$reduction = int(10000*$count_out/$count_in) ;
$reduction = $reduction/100 ;
print "reads in = $count_in\n";
print "reads out = $count_out\n";
print "percent reduction = $reduction\n"; 
close $FASTQ ;
close $FASTQR ;
}

