#!/usr/bin/perl 
##########################################################################################
### Print help ###
my $PrintHelp=qq(
USAGE:
	perl ChooseMaterials.pl <infile.txt> <outfile.txt>

AUTHOR:
	Xukai Li (specterae\@163.com) 2013/01

DESCRIPTION:
	This script was written for picking the choosed samples by 
	calculate the percentage of the increased or decreased level at pair: 
	subtraction of two samples divided by means of two values at pair.
	Written by Xukai Li and test under the perl enviroment 5.12.3.

DATA STRUCTURES:
The data structures of input should as follows (RowNColumnN is your data):
ID 	data1      	data2      	data3        ...  dataN
Id1	Row1Column1	Row1Column2	Row1Column3  ...  Row1ColumnN
Id2	Row2Column1	Row2Column2	Row2Column3  ...  Row2ColumnN
Id3	Row3Column1	Row3Column2	Row3Column3  ...  Row3ColumnN
...	...        	...        	...          ...  ...
IdN	RowNColumn1	RowNColumn2	RowNColumn3  ...  RowNColumnN

EXAMPLE:
	perl  ChooseMaterials.pl  Mydata.txt  Result.txt
\n);
die($PrintHelp)if($ARGV[0]=~/-[hH]+/);
##########################################################################################
### Main ###
die"Incorrect number of command line arguments.\nUsage:  perl ChooseMaterials.pl <infile.txt> <outfile.txt>\n\nTo show brief help usage, do \"perl ChooseMaterials.pl -h\"\n" unless $ARGV[1];
my $choosed=0;

print"\nPlease input the similar parameter and \nfollow the number of column that you choose\n(Separated by Spaces between numbers):\n";
my @col1=split(/\s+/,<STDIN>);
$col1[0]=~/\d+/?(@col1):(@col1=(5,1,2,3));
my $similar=shift(@col1); 	###相似度参数
print"\nPlease input the differences parameter and \nfollow the number of column that you choose\n(Separated by Spaces between numbers):\n";
my @col2=split(/\s+/,<STDIN>);
$col2[0]=~/\d+/?(@col2):(@col2=(20,4,5));
my $differences=shift(@col2); 	###差异度参数
print"\nThe percentage of the increased or decreased level at column:\n\t@col1 is less than $similar\%.\n\nThe percentage of the increased or decreased level at column:\n\t@col2 is greater than $differences\%.\n";

open(DATA,$ARGV[0])||die"Couldn't open infile: $!";
my @data=<DATA>; 	###将所有数据储存在数组@data中
close DATA;
chomp @data;
open(OUTFILE,">$ARGV[1]")||die"Couldn't open outfile: $!";
print OUTFILE join("\t",$data[0],'Sample1','Sample2','Correlation'),"\n";

foreach my $i (1..$#data){ 	###循环不重复的取出将某两行数据
	foreach my $j($i+1..$#data){
		my @row1=split(/\s+/,$data[$i]);
		my @row2=split(/\s+/,$data[$j]);
		foreach my $k (1..$#row1){
			$Col[$k]=($row1[$k]-$row2[$k])/($row1[$k]+$row2[$k])*2*100;
		}
		foreach $col1(@col1){
			$MAX[$col1]=abs($Col[$col1]);
		}
		foreach $col2(@col2){
			$MIN[$col2]=abs($Col[$col2]);
		}
		my $max=max(@MAX); 	###@col1中的最大值
		my $min=min(@MIN); 	###@col2中的最小值
		if($max<$similar and $min>$differences){ 	###满足设置的参数
			$choosed ++;
			$Col[0]='Level';
			my $name1=shift @row1;
			my $name2=shift @row2;
			my $correlation=pearson(\@row1,\@row2); 	###计算这两组数据的相关系数
			print OUTFILE join("\t",@Col),"\t$name1\t$name2\t$correlation\n",join("\t",$name1,@row1),"\n",join("\t",$name2,@row2),"\n";
		}
	}
}
close OUTFILE;
print"\nThe number of samples:\t$#data\nThe number of choosed:\t$choosed\nYour outfile of result \<$ARGV[1]\> is in the folder: > ";
system"cd";
##########################################################################################
### sub ###
###该子程序用于输出数组中的最大值###
sub max{
	my $max=shift;
	$max=$_>$max?$_:$max for @_;
	return $max;
}
###该子程序用于输出数组中的最小值###
sub min{
	my $min=100000;
	for(@_){
		if($_=~/\d+/ and $_<$min){
			$min=$_;
		}
	}
	return $min;
}
###该子程序用于计算两行数据的相关系数###
sub pearson{
	my ($ref_a,$ref_b)=@_;
	my @x=@{$ref_a};
	my @y=@{$ref_b};
	if($#x==$#y){
		my $N=$#x;
		my $sum_sq_x=0;
		my $sum_sq_y=0;
		my $sum_coproduct=0;
		my $mean_x=$x[1];
		my $mean_y=$y[1];
		for (my $i=2;$i<=$N;$i++){
			my $sweep=($i-1.0)/$i;
			my $delta_x=$x[$i]-$mean_x;
			my $delta_y=$y[$i]-$mean_y;
			$sum_sq_x+=$delta_x*$delta_x*$sweep;
			$sum_sq_y+=$delta_y*$delta_y*$sweep;
			$sum_coproduct+=$delta_x*$delta_y*$sweep;
			$mean_x+=$delta_x/$i;
			$mean_y+=$delta_y/$i;
		}
		my $pop_sd_x=sqrt($sum_sq_x);
		my $pop_sd_y=sqrt($sum_sq_y);
		my $cov_x_y=$sum_coproduct;
		my $correlation=$cov_x_y/($pop_sd_x*$pop_sd_y);
		return $correlation;
	}
}
