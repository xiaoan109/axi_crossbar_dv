#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <assert.h>
#ifdef WIN32
#	include <windows.h>
#	include <io.h>
#endif
#include "gen_amba_axi.h"

int main(int argc, char *argv[]) {
  extern void sig_handle(int);
  extern int  arg_parser(int, char **);
  extern char license[];
  extern unsigned int numM, numS;
  extern char module[];
  extern char prefix[];
  extern FILE* fo;

  if ((signal(SIGINT, sig_handle)==SIG_ERR)
#ifndef WIN32
	  ||(signal(SIGQUIT, sig_handle)==SIG_ERR)
#endif
	  ) {
        fprintf(stderr, "Error: signal error\n");
        exit(1);
  }

  if (arg_parser(argc, argv)) return 1;

fprintf(fo, "//******************************************************\n");
fprintf(fo, "// CICC5091, generated axi_crossbar module\n");
fprintf(fo, "//******************************************************\n");

  if (gen_axi_amba( numM, numS, module, prefix, fo )) return 1;

  return(0);
}
//--------------------------------------------------------
void sig_handle(int sig) {
  extern void cleanup();
  switch (sig) {
  case SIGINT:
#ifndef WIN32
  case SIGQUIT:
#endif
       exit(0);
       break;
  }
}