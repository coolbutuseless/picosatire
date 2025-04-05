
#define R_NO_REMAP

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>

#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>


#include "picosat.h"



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// As suggested by Simon Urbanek
// https://stat.ethz.ch/pipermail/r-devel/2011-April/060702.html
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
static void chkIntFn(void *dummy) {
  R_CheckUserInterrupt();
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// this will call the above in a top-level context so it won't longjmp-out of your context
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool checkInterrupt(void) {
  return (R_ToplevelExec(chkIntFn, NULL) == FALSE);
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Callback for 'picosat_set_interrupt()'
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int check_interrupts(void *state) {
  bool res = checkInterrupt();
  if (res) {
    Rprintf("pico_solve(): User interupt\n");
  }
  return res;
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// All in one
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SEXP pico_solve_(SEXP literals_, SEXP limit_, SEXP non_dummy_idx_) {
  int nprotect = 0;
  int n = Rf_length(literals_);
  if (n == 0) {
    // UNSATISFIABLE.  Really an invalid model
    Rf_error("No literals");
  }
  
  SEXP ll_ = PROTECT(Rf_allocVector(VECSXP, Rf_asInteger(limit_))); nprotect++;
  
  
  PicoSAT *pico = picosat_init();
  
  // During 'solve', picosat will check for interupts using this function
  picosat_set_interrupt(pico, NULL, check_interrupts);
  
  int *literals = INTEGER(literals_);
  
  for (int i = 0; i < n; i++) {
    picosat_add(pico, literals[i]);
  }
  
  // Insert a '0' at the end if there wasn't one already
  if (literals[n - 1] != 0) {
    picosat_add(pico, 0);
  }
  
  // solve it
  int nsol = 0;
  while(nsol < Rf_asInteger(limit_)) {
    int res = picosat_sat(pico, -1);
    SEXP res_ = R_NilValue;
    
    if (res == PICOSAT_SATISFIABLE) {
      int n = picosat_variables(pico);
      res_ = PROTECT(Rf_allocVector(INTSXP, n));
      int *resp = INTEGER(res_);
      for (int i = 1; i <= n; i++) {
        int val = picosat_deref(pico, i);
        resp[i - 1] = val * i;
      }
      SET_VECTOR_ELT(ll_, nsol, res_);
      UNPROTECT(1);
      nsol++;
      
      // Block solution
      resp = INTEGER(res_);
      if (Rf_isNull(non_dummy_idx_) || Rf_length(non_dummy_idx_) == 0) {
        // block ALL variables
        for (int i = 0; i < n; i++) {
          picosat_add(pico, -resp[i]);
        }
      } else {
        // Only block the non-dummy variables
        int *non_dummy_idx = INTEGER(non_dummy_idx_);
        for (int i = 0; i < Rf_length(non_dummy_idx_); i++) {
          picosat_add(pico, -resp[non_dummy_idx[i]]);
        }
      }
      
      
      // finish blocking solution
      picosat_add(pico, 0);
    } else {
      break;
    }
  }
  
  if (nsol == 0) {
    // Problem is unsatisfiable
    picosat_reset(pico);
    UNPROTECT(nprotect);
    return R_NilValue;
  }
  
  if (nsol != Rf_asInteger(limit_)) {
    // Need to resize the list result to the actual size
    ll_ = PROTECT(Rf_lengthgets(ll_, nsol)); nprotect++;
  }
  
  
  picosat_reset(pico);
  UNPROTECT(nprotect);
  return ll_;
}



