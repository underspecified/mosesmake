#!/usr/bin/ruby

require "#{File.dirname(__FILE__)}/bleulib"

if ARGV.size < 5
	puts "ruby #{__FILE__} [seed] [iter_num] [Significance Level(%)] [System result] [Reference..]"
	exit 1
end

seed = ARGV.shift.to_i
itr = ARGV.shift.to_i

siglevel = ARGV.shift.to_f/100.0
systemres = ARGV.shift
ref = ARGV

srand seed

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

result = openfile(systemres)
reference = ref.map{|fname| openfile(fname)}

num = result.size

bleus = []

counter = 0
puts "[itr]\t[system BLEU]"

(1..itr).each{|i|
	counter += 1
	tmpres = []
	tmpref = []
	idxs = JnMtLib.randext(num,num)
	
	idxs.each{|k|
		tmpres << result[k]
		reference.each_index{|refid|
			tmpref[refid] ||= []
			tmpref[refid] << reference[refid][k]
		}
	}

	if tmpref.length == 1
		bleus << JnMtLib.calc_BLEU(tmpres,tmpref[0]) 
	else
		bleus << JnMtLib.calc_multi_BLEU(tmpres,tmpref) 
	end

	puts "#{counter}\t#{bleus[-1]}"
}

bleus.sort!

puts "#{counter} times iterated."
cutnum = ((itr * (1.0-siglevel))/2.0).to_i

puts "#{siglevel*100}% significance level is from No.#{cutnum+1} to No.#{counter-cutnum} when sorted by BLEU score."

puts "#{bleus[cutnum]} <= SYSTEM BLEU <= #{bleus[-cutnum-1]}"

