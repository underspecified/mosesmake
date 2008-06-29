#!/usr/bin/ruby

require "#{File.dirname(__FILE__)}/bleulib"

if ARGV.size < 5
	puts "ruby #{__FILE__} [seed] [iter] [System1 Result] [System2 Result] [Reference..]"
	exit 1
end

seed = ARGV.shift.to_i
itr = ARGV.shift.to_i

input_base = ARGV.shift
input_new = ARGV.shift

test_ja = ARGV

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

base = openfile(input_base)
nr = openfile(input_new)
testja = test_ja.map{|fname| openfile(fname)}

num = base.size

counter_base = 0
counter_new = 0
counter_equal = 0
print "[system1 BLEU]\t[system2 BLEU]\t[system1 win]\t[system2 win]\t[draw]\n"

(1..itr).each{|i|
	tmptestja = []
	tmpbase = []
	tmpnr = []
	idxs = JnMtLib.randext(num,num)
	
	idxs.each{|k|
		testja.each_index{|refid|
			tmptestja[refid] ||= []
			tmptestja[refid] << testja[refid][k]
		}
	}
	
	idxs.each{|k|
	 tmpbase << base[k]
	}

	idxs.each{|k|
	 tmpnr << nr[k]
	}

	bleu_base = nil
	bleu_new = nil
	if tmptestja.length == 1
		bleu_base = JnMtLib.calc_BLEU(tmpbase,tmptestja[0]) 
		bleu_new = JnMtLib.calc_BLEU(tmpnr,tmptestja[0])
	else
		bleu_base = JnMtLib.calc_multi_BLEU(tmpbase,tmptestja) 
		bleu_new = JnMtLib.calc_multi_BLEU(tmpnr,tmptestja)
	end

	r = [bleu_base.to_f,bleu_new.to_f]
	print r.join("\t"),"\t"
	if r[0] < r[1]
		counter_new += 1
	elsif r[0] > r[1]
		counter_base += 1
	else
		counter_equal += 1
	end
	print [counter_base,counter_new,counter_equal].join("\t"),"\n"
}

print "system1:",counter_base,"\n"
print "system2:",counter_new,"\n"
print "draw:", counter_equal,"\n"

