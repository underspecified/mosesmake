#!/usr/bin/ruby

module JnMtLib
	def randext(n,max)
	  counter = 0

	  ret = []

	  while counter < n
	    id = rand(max)
	    ret << id
	    counter += 1
	  end
	  ret
	end

	def count_ngrams(tws, rws,n)
		totalcount = 0
		clipcount = 0

		rws.each_index{|j|
			lws = rws[j]
			rngcount = {}
			0.upto(lws.length-n){|i|
				ss = lws[i,n]
				if rngcount[ss] == nil
					rngcount[ss] = 1
				else
					rngcount[ss] += 1
				end
			}

			lws = tws[j]

			tngcount = {}
			tc = lws.length-n+1
			if tc > 0
				totalcount += tc
			else
				totalcount += lws.length
			end

      0.upto(lws.length-n){|i|
        ss = lws[i,n]
        if tngcount[ss] == nil
          tngcount[ss] = 1
        else
          tngcount[ss] += 1
        end
      }

			rngcount.each{|key,value|
				c = tngcount[key]
				next if c == nil
				if c < value
					clipcount += c
				else
					clipcount += value
				end
			}
		}

		[clipcount, totalcount]
	end

	def calc_BLEU(target, reference)
		calc_ngram_BLEU(target, reference, 4)
	end

	def calc_ngram_BLEU(target, reference,ngram)
		throw "array size mismatch" if target.length > reference.length

		r = 0
		rwords = []
		reference.each{|line|
			rwords << line.split
			r += rwords[-1].length
		}

		c = 0
		twords = []
		target.each{|line|
			twords << line.split
			c += twords[-1].length
		}

		bp = 1.0
		bp = Math.exp(1.0-r.to_f/c.to_f) if c <= r
		
		wn = 1.to_f/ngram.to_f

		pn = []

		1.upto(ngram){|n|
			correctnum,total = count_ngrams(twords,rwords,n)
			pn[n] = correctnum.to_f/total.to_f
		}

		pp = 1.0
		ngram.times{|n|
			pp *= pn[n+1]
		}
		
		if pp != 0.0
			bleu = bp * Math.exp(wn * Math.log(pp))
		else
			bleu = 0.0
		end
	end

	def calc_multi_BLEU(target, references)
		calc_ngram_multi_BLEU(target, references, 4)
	end

	def count_multi_ngrams(tws, rwss,n)
		tcount = 0
		clipcount = 0

		tws.each_index{|lidx|
			tline = tws[lidx]
			tc = tline.length-n+1
			tnum = (tc < 0)? tline.length : tc
			tcount += tnum
			
			tngrams = {}
			tline.each_index{|tidx|
				break if tidx == tnum
				twords = tline[tidx,n]
				tngrams[twords] ||= 0
				tngrams[twords] += 1
			}

			rngramss = []
			rwss.each{|rws|
				rngrams = {}
				rline = rws[lidx]
				rc = rline.length-n+1
				rnum = (rc < 0)? rline.length : rc
				rline.each_index{|ridx|
					break if ridx == rnum
					rwords = rline[ridx,n]
					rngrams[rwords] ||= 0
					rngrams[rwords] += 1
				}
				
				rngramss << rngrams
			}

			tngrams.each{|tngram, tnc|
				rnc = 0
				rngramss.each{|rngrams|
					next if rngrams[tngram] == nil
					rnc = rngrams[tngram] if rnc < rngrams[tngram]
				}
				clipcount += (rnc > tnc)? tnc : rnc
			}
		}
		[clipcount, tcount]
	end

	def calc_ngram_multi_BLEU(target, references, ngram)
		$stderr.puts "Worning: Multi-BLEU is currently beta-version."

		refs = references.map{|reference|
			reference.map{|rline|
				rline.split
			}
		}

		tgt = target.map{|tline|
			tline.split
		}
		
		r = 0
		c = 0
		tgt.each_with_index{|tline, tindex|
			tlen = tline.length
			c += tlen

			cr = 0
			closest_length = 43254353425
			refs.each{|rline|
				rlen = rline[tindex].length
				length_distance = (rlen - tlen).abs
				if length_distance <= closest_length
					closest_length = length_distance
					cr = rlen if cr > rlen
				end
			}
			r += cr
		}

		pscore = []
		(1..ngram).each{|mgram|
			clipcount, tcount = count_multi_ngrams(tgt, refs, mgram)
			return 0.0 if clipcount == 0
			pscore << clipcount.to_f/tcount
		}

		bp = (c > r)? 1.0 : Math.exp(1-(r.to_f/c))

		prebleu = 0.0
		pscore.each{|ps|
			prebleu += Math.log(ps)/4.0
		}
		bleu = bp * Math.exp(prebleu)
	end
	
	module_function :calc_BLEU, :count_ngrams, :count_multi_ngrams, :calc_ngram_BLEU, :randext, :calc_ngram_multi_BLEU, :calc_multi_BLEU
end

