#!/usr/bin/ruby

require "#{File.dirname(__FILE__)}/bleulib"

if ARGV.size < 2
	puts "Usage: ruby #{__FILE__} [Translation Result] [Reference...]"
	exit(1)
end

target = ARGV.shift
ref = ARGV

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

ts = openfile(target)
rs = ref.map{|fname| openfile(fname)}

if rs.length != 1
	print "BLEU Score(%):", JnMtLib::calc_multi_BLEU(ts,rs) * 100, "\n"
else
	print "BLEU Score(%):", JnMtLib::calc_BLEU(ts,rs[0]) * 100, "\n"
end

