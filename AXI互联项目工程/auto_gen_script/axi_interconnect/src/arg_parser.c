#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>
#ifdef WIN32
#	include <windows.h>
#	include <io.h>
#endif

int verbose=0;
unsigned int numM=2;
unsigned int numS=2;
char module[128]="\0\0";
char prefix[128]="\0\0";
char file[256]="\0\0";
FILE *fo;

//-----------------------------------------------------
//     *name,  has_arg, *flag, val
// if (flag==NULL) getopt_long return 'val'.
// otherwise, getopt_long returns 0, and '*flag' is set by 'val'.
static struct option longopts[] = {
       {"mst" , required_argument, 0, 'm'}
     , {"slv" , required_argument, 0, 's'}
     , {"mod" , required_argument, 0, 'd'}
     , {"pre" , required_argument, 0, 'p'}
     , {"out" , required_argument, 0, 'o'}
     , {"ver" , required_argument, 0, 'v'}
     , {"lic" , no_argument      , 0, 'l'}
     , { 0    , 0                , 0,  0 }
};

//--------------------------------------------------------
// 1. get simulator options from command line
// 2. returns 0 on successful completion
int arg_parser(int argc, char **argv) {
  int opt;
  int longidx=0;
  extern void help(int, char **);

  //-----------------------------------------------------
  while ((opt=getopt_long(argc, argv, "m:s:d:p:o:v:lh?", longopts, &longidx))!=-1) {
     switch (opt) {
     case 'm': numM = atoi(optarg); break;
     case 's': numS = atoi(optarg); break;
     case 'd': strcpy(module,optarg); break;
     case 'p': strcpy(prefix,optarg); break;
     case 'o': strcpy(file,optarg); break;
     case 'v': verbose = atoi(optarg); break;
     case 'h':
     case '?': help(argc, argv); exit(0); break;
     case  0 : //if (longopts[longidx].flag) printf("%d:%s\n", opt, longopts[longidx].name);
               //if (longopts[longidx].flag!=0) break;
               //strcpy(file,optarg);
               break;
     default: 
        fprintf(stderr, "undefined option: %c\n", optopt);
        help(argc, argv);
        exit(1);
     }
  }
  if (prefix[0]!='\0') {
      if ((prefix[0]<'A')||(prefix[0]>'z')||
          ((prefix[0]>'Z')&&(prefix[0]<'a'))) {
          fprintf(stderr, "prefix should start with alphabet, not %c.\n", prefix[0]);
          return 1;
      }
  }
  if (file[0]!='\0') {
      #ifdef WIN32
      fo = fopen(file, "wb");
      #else
      fo = fopen(file, "w");
      #endif
      if (fo==NULL) {
          fprintf(stderr, "file open error\n");
          return 1;
      }
  } else {
    fo = stdout;
  }
  if (module[0]=='\0') {
      sprintf(module, "amba_axi_m%ds%d", numM, numS);
  }
  return 0;
}
#undef XXTX

//--------------------------------------------------------
void help(int argc, char **argv)
{
  fprintf(stderr, "[Usage] %s [options]\n", argv[0]);
  fprintf(stderr, "\t-m,--mst=num    num of masters (default: %u)\n", numM);
  fprintf(stderr, "\t-s,--slv=num    num of slaves  (default: %u)\n", numS);
  fprintf(stderr, "\t-d,--mod=str    module name (default: \"amba_axi_mXsY\")\n");
  fprintf(stderr, "\t-p,--pre=str    prefix of module (default: none)\n");
  fprintf(stderr, "\t-o,--out=file   output file name (stdout if not given)\n");
  fprintf(stderr, "\t-v,--ver=num    verbose level  (default: %d)\n", verbose);
  fprintf(stderr, "\t-l,--lic        print license message\n");
  fprintf(stderr, "\t-h              print help message\n");
  fprintf(stderr, "\n");
}
