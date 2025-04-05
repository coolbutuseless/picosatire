
// #define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

extern SEXP pico_solve_(SEXP literals_, SEXP limit_, SEXP,  SEXP non_dummy_idx);

static const R_CallMethodDef CEntries[] = {
  
  {"pico_solve_" , (DL_FUNC) &pico_solve_  , 3},
  
  {NULL , NULL, 0}
};


void R_init_picosatire(DllInfo *info) {
  R_registerRoutines(
    info,      // DllInfo
    NULL,      // .C
    CEntries,  // .Call
    NULL,      // Fortran
    NULL       // External
  );
  R_useDynamicSymbols(info, FALSE);
}



