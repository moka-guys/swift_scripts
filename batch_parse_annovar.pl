#!/usr/bin/perl
#input unfiltered VCF format
#output filtered VCF file
#Retains header, column headers and PASS VCF records only
use strict;
use warnings;
my $input_table_name ;
my $filtered_table_name ;
my @raw_table ;
my @filtered_table ;
my $input ;
my $output ;
my @split_line ;
my $fixed_line ;
my $split_line ;
my @split_tab ;
my $split_tab ;
my $allele_freq = "default" ;
my $clinvar ;
my $annovar_out_dir ;
my @file_list;


print "please enter the name of the Annovar output directory\n" ;
$annovar_out_dir = <STDIN> ;
chomp  $annovar_out_dir ;
@file_list = glob"$annovar_out_dir/*multianno.txt";
for $input_table_name(@file_list)
{
	$filtered_table_name = $input_table_name ;
	#$filtered_table_name =~ s/\./\_/g ;
	$filtered_table_name=~ s/txt/tsv/ ;
	#$filtered_table_name =~ s/$/\.tsv/ ;
	open ($input, "< $input_table_name") ;
	#clear @raw_table
	undef(@raw_table) ;
	undef(@filtered_table) ;
	while (<$input>)
	{
		push (@raw_table, $_ ) ;
	}
	close $input ;
	push @filtered_table, "$filtered_table_name\n"; #first line: identifies sample
	push @filtered_table, "chr\tgene\tRefSeq\tcDNA\tprotein\tpercent\tclinvar\n" ; #headers
	for (@raw_table)
	{
		if ($_ =~ m/intronic/ ) # miss intronic variants
			{
			next ;
			}
		unless($_ =~ m/NM_/) #if no refseq, do not print
			{
			next ;
			}
		if ($_ =~ m/PASS/) #must pass qual
 			{
 			@split_line = split("\t");		#split line on tabs: there are 25
 			@split_tab = split(/:/, "$split_line[24]") ;
 			$allele_freq = $split_tab[6] ; #extract allele freq 
 			$allele_freq =~ s/%// ;
 			$clinvar = $split_line[11] ; #clinvar tab
 			$clinvar =~ s/CLINSIG=//;
 			$clinvar =~ s/;.*//;
 			$clinvar =~ s/\|.*//;
 			$fixed_line = "$split_line[0]_$split_line[1]\-$split_line[2]\t$split_line[6]\t$split_line[9]\t$allele_freq\t$clinvar\n";
 		$fixed_line =~ s/:/\t/g ;
 		$fixed_line =~ s/_/:/ ;
 		if($split_line[9] =~ m/NM/)
 			{
 			push  @filtered_table, $fixed_line ;
 			}
 		}
	}
open ($output, ">", "$filtered_table_name") ;
print $output @filtered_table ;
close $output ;
}
exit;

