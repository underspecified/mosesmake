#!/usr/bin/ruby

require "#{File.dirname(__FILE__)}/bleulib"

if ARGV.length < 2
  puts "Usage: ruby line_bleu.rb [options] [translation result] [references...]\n"
	puts "Option:"
	puts "-ngram min:max"
	puts "\tCalc from min-gram to max-gram(default 4:4)"
  exit
end

min = 4
max = 4
if ARGV[0] == "-ngram"
	ARGV.shift
	param = ARGV.shift
	if param =~ /(.+?):(.+?)/
		min = $1.to_i
		max = $2.to_i
	else
		throw "parse error"
	end
end

input_base = ARGV.shift
test_ja = ARGV

def openfile(fname)
	ret = []
	open(fname){|f|
		while f.gets
				chomp!
				ret << $_
		end
	}
	ret
end

base = openfile(input_base)
testja = []
test_ja.each{|tfile|
	testja << openfile(tfile)
}

base.each_index{|i|
	ref = []
	testja.each{|refdat|
		ref << [refdat[i]]
	}

	bleu = []
	if ref.length == 1
		max.downto(min){|n|
			bleu << JnMtLib.calc_ngram_BLEU([base[i]],ref[0],n)
		}
	else
		max.downto(min){|n|
			bleu << JnMtLib.calc_ngram_multi_BLEU([base[i]],ref,n)
		}
	end
	print bleu.join("\t"), "\t", base[i], "\n"
}

