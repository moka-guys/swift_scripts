#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Path;
use Cwd ;
#input blat VCF
#output annovar annotated VCF file
#output summary of vcf as tsv
#Can apply filtering
#Retains header, column headers and PASS VCF records only
=head1 NAME

batch_annotate.pl

=head1 VERSION

0.1

=head1 DESCRIPTION

annovar annotation of amplivar/blat alignments

=head1 INPUT

path to blat vcf files 

=head1 OUTPUT



=head1 OTHER REQUIREMENTS

bash shell
perl
=head1 EXMAPLE USAGE

perl batch_annotate.pl
in directory containing amplivar_out

=head1 AUTHOR

Graham Taylor King's College London

=cut
#variables
our $input_dir = "amplivar_out"; #default name for raw vcf
our @file_list ;
our $output_dir ;
our $sample_ID ;
our $boilerplate ;
#glob dir

print "\tEnter input directory\n";
$input_dir = <STDIN>;
chomp $input_dir;
print "\tEnter output directory\n";
$output_dir = <STDIN> ;
chomp $output_dir ;
mkpath($output_dir) ;
@file_list=glob"$input_dir/*";
print "file list\t@file_list" ;
foreach $sample_ID(@file_list)
{
	$sample_ID =~ s/$input_dir\///;
	$boilerplate = "$input_dir/$sample_ID/$sample_ID".'.blat.vcf /home/oncology/Desktop/annovar/humandb/ -buildver hg19 -out '."$output_dir/$sample_ID".' --onetranscript --otherinfo -remove -protocol refGene,cosmic70,clinvar_20150330 -operation g,f,f -nastring . -vcfinput' ;
	print "$sample_ID\n";
	print "$boilerplate\n";
	#run table annovar
	`table_annovar.pl $boilerplate`;
}
exit;
