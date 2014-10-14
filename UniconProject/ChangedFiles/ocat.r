/*
 * File: ocat.r -- caterr, lconcat
 */
 
#ifdef PatternType
/*	FncDef(pattern_concat,2) */
/*	#include "../h/fdefs.h" */
#endif
 
"x || y - concatenate strings x and y." 
operator{1} || cater(x, y)
   declare {
      int use_trap = 0;
      }

   if is:pattern(x) then {
      inline {
      use_trap = 1;
      }
      abstract {
	 return pattern;
	 }
      }
   else if is:pattern(y) then {
      inline {
      use_trap = 1;
      }
      abstract {
	 return pattern;
	 }
      }
   else if is:cset(x) then {
      inline {
      use_trap = 1;
      }
      abstract {
	 return pattern;
	 }
      }
   else if is:cset(y) then {
      inline {
      use_trap = 1;
      }
      abstract {
	 return pattern;
	 }
      }
   else {
      if !cnv:string(x) then
	 runerr(103, x)
      if !cnv:string(y) then
	 runerr(103, y)
      }

   abstract {
      return string
      }

   body {
      if (use_trap == 1) {
      
	 union block *bp;
	 /* convert strings to pattern blocks */
	 struct b_pattern *lp;
	 struct b_pattern *rp;
	 struct b_pelem *pe;
	 type_case x of {
	    string:
	       cnv_str_pattern(&x,&x);
	    cset:
	       cnv_cset_pattern(&x,&x);
	    pattern: {
	       }
	    default:{
	       runerr(127);
	       }
	       }
	 type_case y of {
	    string:
	       cnv_str_pattern(&y,&y);
	    cset:
	       cnv_cset_pattern(&y,&y);
	    pattern: {
	       }
	    default:{
	       runerr(127);
	       }
	       }

	 lp = (struct b_pattern *)BlkLoc(x);
	 rp = (struct b_pattern *)BlkLoc(y);

	 /* perform concatenation in patterns */
	 pe = Concat(Copy((struct b_pelem *)lp->pe), Copy((struct b_pelem *)rp->pe), rp->stck_size);
	 bp = pattern_make_pelem(lp->stck_size + rp->stck_size,pe);
	 return pattern(bp);
	 }
      else {
     
	 CURTSTATE();

	 /*
	  *  Optimization 1:  The strings to be concatenated are already
	  *   adjacent in memory; no allocation is required.
	  */
	 if (StrLoc(x) + StrLen(x) == StrLoc(y)) {
	    StrLoc(result) = StrLoc(x);
	    StrLen(result) = StrLen(x) + StrLen(y);
	    return result;
            } 
	 else 
	    if ((StrLoc(x) + StrLen(x) == strfree) && (DiffPtrs(strend,strfree) > StrLen(y))) {
	       /*
		* Optimization 2: The end of x is at the end of the string space.
		*  Hence, x was the last string allocated and need not be
		*  re-allocated. y is appended to the string space and the
		*  result is pointed to the start of x.
		*/
	       result = x;
	       /*
		* Append y to the end of the string space.
		*/
	       Protect(alcstr(StrLoc(y),StrLen(y)), runerr(0));
	       /*
		*  Set the length of the result and return.
		*/
	       StrLen(result) = StrLen(x) + StrLen(y);
	       return result;
	       }

	 /*
	  * Otherwise, allocate space for x and y, and copy them
	  *  to the end of the string space.
	  */
	 Protect(StrLoc(result) = alcstr(NULL, StrLen(x) + StrLen(y)), runerr(0));
	 memcpy(StrLoc(result), StrLoc(x), StrLen(x));
	 memcpy(StrLoc(result) + StrLen(x), StrLoc(y), StrLen(y));

	 /*
	  *  Set the length of the result and return.
	  */
	 StrLen(result) = StrLen(x) + StrLen(y);
	 return result;
	 }
   }
end


"x ||| y - concatenate lists x and y."

operator{1} ||| lconcat(x, y)
   /*
    * x and y must be lists.
    */
   if !is:list(x) then
      runerr(108, x)
   if !is:list(y) then
      runerr(108, y)

   abstract {
      return new list(store[(type(x) ++ type(y)).lst_elem])
      }

   body {
      register struct b_list *bp1;
      register struct b_lelem *lp1;
      word size1, size2, size3;

      /*
       * Get the size of both lists.
       */
      size1 = BlkD(x,List)->size;
      size2 = BlkD(y,List)->size;
      size3 = size1 + size2;

      Protect(bp1 = (struct b_list *)alclist_raw(size3, size3), runerr(0));
      lp1 = (struct b_lelem *) (bp1->listhead);

      /*
       * Make a copy of both lists in adjacent slots.
       */
      cpslots(&x, lp1->lslots, (word)1, size1 + 1);
      cpslots(&y, lp1->lslots + size1, (word)1, size2 + 1);

      BlkLoc(x) = (union block *)bp1;

      EVValD(&x, E_Lcreate);

      return x;
      }
end
