Mapping 36 numeric and character variables to deciles, ranks, LOW, HI, 1st, 2nd and 3rd ....

Oroginal Topic: Categorizing huge amount of variables

https://goo.gl/79bKof
https://communities.sas.com/t5/SAS-Data-Management/Categorizing-huge-amount-of-variables/m-p/429465

INPUT
=====

   * these macro variables are created in my autoexec;

   %let numbersq=%str("1","2","3","4","5","6","7","8","9","0");

   %let lettersq=%str(
     "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G" ,"H" ,"I" ,"J" ,"K" ,"L"
    ,"M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z");

   %let letters=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z;

   %let numbers=1 2 3 4 5 6 7 8 9 0;


   MAPPINGS
   ========

     $chr1st

       "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G" ,"H" ,"I" ,"J" ,"K" ,"L"        ="LOW"
       "M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z"="HI"

     $chr2nd
       "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G"                                  ="1ST"
       "H" ,"I" ,"J" ,"K" ,"L"                                            ="2ND"
       "M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z"="3RD"

     format rnk

        rnk=put(round(rank(ltr),10),2.);

        "A"="60"
        "B"="60"
        ...

        "J"="70"

     fmtround

      0-1 = '9th Decile' (mult=10);   * rounds frations to deciles .1= 1st Decile

  WORK.MAPPING
  ============

     WORK.MAPPING total obs=36 Mappings

        VAR    MAPPING (functions)

        N1     z4.1
        N2     4.1
        N3     fmtround.
      ...
        N8     4.1
        N9     fmtround.
      ...
        A      $chr2nd.
        B      $rnk.
        C      $chr1st.
      ...
        Y      $chr2nd.
        Z      $rnk.


WORK.HAVE total obs=1,000
==========================

  A  B  C  D ...  Z      N0    N1    N2  ...  N9

  N  I  V  A ...  K     0.02  0.58  0.39 ... 0.49
  Z  B  J  S ...  U     0.06  0.49  0.36 ... 0.70
  C  D  W  Q ...  P     0.08  0.13  0.53 ... 0.96
  R  V  M  G ...  U     0.23  0.66  0.74 ... 0.06
  G  V  X  N ...  Z     0.50  0.28  0.38 ... 0.67
  V  B  J  U ...  U     0.99  0.91  0.72 ... 0.73
  Y  L  I  A ...  F     0.43  0.58  0.04 ... 0.22
  G  F  P  X ...  D     0.93  0.72  0.39 ... 0.13
  F  B  P  A ...  P     0.24  0.34  0.14     1.00
 ...


PROCESS
=======

data _null_;

  * create SQL selwct clause that maps the raw data;
  if _n_=0 then do;
     %let rc=%sysfunc(dosubl('
         proc sql;
            select
               catx(" ",",put(",var,",",mapping,") as",var)
            into
               :reFmt separated by " "
            from
               mapping
         ;quit;
     '));
   end;

   /* macro variable reFmt contains

      ,put( N1 , z4.1 )      as N1
      ,put( N2 , 4.1 )       as N2
      ,put( N3 , fmtround. ) as N3
     ...
      ,put( N8 , 4.1 )       as N8
      ,put( N9 , fmtround. ) as N9
     ...
      ,put( N0 , z4.1 )      as N0

      ,put( A , $chr2nd. )   as A
      ,put( B , $rnk. )      as B
      ,put( C , $chr1st. )   as C
     ...
      ,put( Y , $chr2nd. )   as Y
      ,put( Z , $rnk. )      as Z

   */

   rc=dosubl('
      proc sql;
        create
           table want as
        select
          "Mapped"  as Mapped
          &refmt
        from
          have
        ;quit;
      ');

run;quit;


OUTPUT
======

 WORK.WANT total obs=1,000

  MAPPED  N1  N2      N3     ...      N9      A  B  C   D  ...   Y   Z

  Mapped 00.6 0.4 6th Decile ... 5th Decile  3RD 7 HI  1ST ...  2ND  7
  Mapped 00.5 0.4 3th Decile ... 7th Decile  3RD 7 LOW 3RD ...  1ST  8
  Mapped 00.1 0.5 2th Decile ... 0th Decile  1ST 7 HI  3RD ...  2ND  8
  Mapped 00.7 0.7 5th Decile ... 1th Decile  3RD 8 LOW 1ST ...  3RD  8
  Mapped 00.3 0.4 0th Decile ... 7th Decile  1ST 9 HI  3RD ...  3RD  9
  Mapped 00.9 0.7 5th Decile ... 7th Decile  3RD 7 LOW 3RD ...  1ST  8
  Mapped 00.6 0.0 8th Decile ... 2th Decile  3RD 8 LOW 1ST ...  1ST  7

 SAMPLE Frequencies for 5 of the 36 variables;

  proc freq data=want;
   tables N2 N3 A B C;
  run;quit;

  A        Frequency
  ------------------
  1ST         294
  2ND         188
  3RD         518

  B
  ------------------
  7           391
  8           385
  9           224

  C
  ------------------
  HI          539
  LOW         461


  N2      Frequency
 ------------------
  0.0          53
  0.1         101
  0.2          93
  0.3          84
  0.4         110
  0.5          80
  0.6         118
  0.7         105
  0.8          95
  0.9         119
  1.0          42

 N3
 ------------------
  0th Decile    110
  1th Decile     93
  2th Decile    103
  3th Decile    105
  4th Decile    105
  5th Decile    106
  6th Decile    102
  7th Decile     96
  8th Decile     92
  9th Decile     88

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

proc datasets lib=work kill;
run;quit;

%symdel reFmt lettersc letters numbers numbersc / nowarn;

%let numbersq=%str("1","2","3","4","5","6","7","8","9","0");

%let lettersq=%str(
"A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G" ,"H" ,"I" ,"J" ,"K" ,"L"
,"M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z");

%let letters=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z;


* round value to the nearest percent;
proc format;
 picture fmtround (round)
 0-1 = '9th Decile' (mult=10);
 ;
run;quit;

data;x=.49;y=put(x,fmtround.); put y=;run;quit;

proc format;
  value $chr1st
    "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G" ,"H" ,"I" ,"J" ,"K" ,"L"        ="LOW"
    "M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z"="HI"
  ;
  value $chr2nd
    "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G"                                  ="1ST"
    "H" ,"I" ,"J" ,"K" ,"L"                                            ="2ND"
    "M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z"="3RD"
;run;quit;


* these mnacro variables are created in my autoexec;

%let numbersc=%str("1","2","3","4","5","6","7","8","9","0");

* functions in formata Rick Langston;
proc fcmp outlib=work.functions.locase;
  function rnk(ltr $) $1;
    rnk=put(round(rank(ltr),10),2.);
  return(rnk);
endsub;
run;quit;

options cmplib=(work.functions);
proc format;
  value $rnk other=[rnk()];
run;quit;


* build mapping dataset;
data mapping;

   array ltrs[26] $1 (&lettersq);
   array nums[10] $1 (&numbersq);
   do i=1 to dim(nums);
      var=cats('N',nums[i]);
     select (mod(i,3));
      when(0)  mapping='fmtround.';
      when(1)  mapping='z4.1';
      when(2)  mapping='4.1';
     end; * leave off otherwise;
     keep var mapping;
     output;
   end;
   do i=1 to dim(ltrs);
     var=ltrs[i];
     select (mod(i,3));
      when(0)  mapping='$chr1st.';
      when(1)  mapping='$chr2nd.';
      when(2)  mapping='$rnk.';
     end; * leave off otherwise;
     output;
   end;

run;quit;

* build input raw data;
data have(drop=rec num ltr);;
   array ltrs[26] $1 &letters;
   array alfa[26] $1 _temporary_ (&lettersq);
   array nums[10] n0-n9;
   do rec=1 to 1000;
     do num=1 to dim(nums);
        nums[num]=round(uniform(5731),.01);
     end;
     do ltr= 1 to dim(ltrs);
        ltrs[ltr]=byte(int(25*uniform(5732))+65);
     end;
     output;
   end;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


data _null_;

  if _n_=0 then do;
     %let rc=%sysfunc(dosubl('
         proc sql;
            select
               catx(" ",",put(",var,",",mapping,") as",var)
            into
               :reFmt separated by " "
            from
               mapping
         ;quit;
     '));
   end;

   rc=dosubl('
      proc sql;
        create
           table want as
        select
          "Mapped"  as Mapped
          &refmt
        from
          have
        ;quit;
      ');

run;quit;

*_
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
;


2238  data _null_;
2239    * create SQL selwct clause that maps the raw data;
2240    if _n_=0 then do;
2241       %let rc=%sysfunc(dosubl('
2242           proc sql;
2243              select
2244                 catx(" ",",put(",var,",",mapping,") as",var)
2245              into
NOTE: PROCEDURE SQL used (Total process time):
      real time           0.04 seconds
      user cpu time       0.00 seconds
      system cpu time     0.03 seconds
      memory              3691.18k
      OS Memory           20204.00k
      Timestamp           01/21/2018 02:45:20 PM
      Step Count                        401  Switch Count  0


2246                 :reFmt separated by " "
2247              from
2248                 mapping
2249           ;quit;
2250       '));
2251     end;
2252     rc=dosubl('
2253        proc sql;
2254          create
2255             table want as
2256          select
2257            "Mapped"  as Mapped
2258            &refmt
2259          from
2260            have
2261          ;quit;
2262        ');
2263  run;

SYMBOLGEN:  Macro variable REFMT resolves to ,put( N1 , z4.1 ) as N1 ,put( N2 , 4.1 ) as N2 ,put( N3
            , fmtround. ) as N3 ,put( N4 , z4.1 ) as N4 ,put( N5 , 4.1 ) as N5 ,put( N6 , fmtround. )
            as N6 ,put( N7 , z4.1 ) as N7 ,put( N8 , 4.1 ) as N8 ,put( N9 , fmtround. ) as N9 ,put(
            N0 , z4.1 ) as N0 ,put( A , $chr2nd. ) as A ,put( B , $rnk. ) as B ,put( C , $chr1st. )
            as C ,put( D , $chr2nd. ) as D ,put( E , $rnk. ) as E ,put( F , $chr1st. ) as F ,put( G ,
            $chr2nd. ) as G ,put( H , $rnk. ) as H ,put( I , $chr1st. ) as I ,put( J , $chr2nd. ) as
            J ,put( K , $rnk. ) as K ,put( L , $chr1st. ) as L ,put( M , $chr2nd. ) as M ,put( N ,
            $rnk. ) as N ,put( O , $chr1st. ) as O ,put( P , $chr2nd. ) as P ,put( Q , $rnk. ) as Q
            ,put( R , $chr1st. ) as R ,put( S , $chr2nd. ) as S ,put( T , $rnk. ) as T ,put( U ,
            $chr1st. ) as U ,put( V , $chr2nd. ) as V ,put( W , $rnk. ) as W ,put( X , $chr1st. ) as
            X ,put( Y , $chr2nd. ) as Y ,put( Z , $rnk. ) as Z
NOTE: Table WORK.WANT created, with 1000 rows and 37 columns.

NOTE: PROCEDURE SQL used (Total process time):
      real time           0.09 seconds


NOTE: DATA statement used (Total process time):
      real time           0.25 seconds

2263!     quit;

*            _
  __ _ _   _| |_ ___   _____  _____  ___
 / _` | | | | __/ _ \ / _ \ \/ / _ \/ __|
| (_| | |_| | || (_) |  __/>  <  __/ (__
 \__,_|\__,_|\__\___/ \___/_/\_\___|\___|

;


/* this autoexec is located in &_r/oto/Tut_Oto.sas */
* generally I do not like to set nofmterr but client has many datasets with missing user formats;
options ls=171 ps=65 cmdmac nofmterr nocenter nodate nonumber noquotelenmax validvarname=upcase
compress=no FORMCHAR='|----|+|---+=|-/\<>*';

/*--------------------------------------------------------------*\
|                                                                |
| Versioning _q provides starting suffix                         |
|                                                                |
\*--------------------------------------------------------------*/

/* number of seconds into the day for versioning */
%Let _q=%sysfunc(int(%sysfunc(time())));  * used in versioning save current program in c:/ver with timestamp added (on  mmb);

%global _r _p _o; * not rally needed but good for doc;

* change root for other systems;
%let _r=c:;
%let _p=&_r/utl; * program directory;
%let _o=&_r/oto; * user autocall folder;

ods results off;

options cmplib=work.funcs;

* encrypt;
options fmtsearch=(work.formats mta.mta_formats_v1f mta.var2des);
proc fcmp outlib=work.functions.hashssn;
function encrypt(ssn);
    length rev $17;
    key=8192;
    ssn_remainder = mod(ssn, key);
    ssn_int       = round((ssn - ssn_remainder)/key,1);
    * 8192  ssn_remainder = 1 and ssn_int = 1 ie 1*key + 1 = original value;
    ssn_big   = ssn_int*100000 + ssn_remainder;
    rev=reverse(put(ssn_big,17.));
    if substr(rev,1,1)=0 then rev=cats('-1',substr(rev,2));
    ssn_encrypt=input(rev,17.);
  return(ssn_encrypt);
endsub;
run;quit;

* decrypt;
proc fcmp outlib=work.functions.hashssn;
function decrypt(ssn);
    length rev $17;
    key=8192;
    rev=strip(reverse(put(ssn,17.)));
    if index(rev,'-')>0 then substr(rev,index(rev,'-')-1)='0 ';
    ssn_big=input(rev,17.);
    ssn_decrypt   = round(ssn_big/100000,1)*key + mod(ssn_big,10000);
  return(ssn_decrypt);
endsub;
;run;quit;

*swap;
proc fcmp outlib=work.functions.swap;
  subroutine swapn(a,b);
  outargs a, b;
      h = a; a = b; b = h;
  endsub;
  subroutine swapc(a $,b $);
  outargs a, b;
      h = a; a = b; b = h;
  endsub;
run;quit;

ods listing;

proc format;

  value num2mis
   . = 'MIS'
   0 = 'ZRO'
   0<-high = "POS"
   low-<0 = 'NEG'
   other='POP'
   ;
   value $chr2mis
   'Unknown',' ','UNK','U','NA','UNKNOWN','Missing','MISSING','MISS' ='MIS'
   other='POP'
    ;
run;


%let numbersq=%str("1","2","3","4","5","6","7","8","9","0");

%let lettersq=%str(
  "A" ,"B" ,"C" ,"D" ,"E" ,"F" ,"G" ,"H" ,"I" ,"J" ,"K" ,"L"
 ,"M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X","Y" ,"Z");

%let letters=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z;

%let numbers=1 2 3 4 5 6 7 8 9 0;



/* Sorens formula evaluator
%macro testexpr(expr='2*exp(3)');
data _null_;
  length x 8;
  x=%sysfunc(dequote(&expr));
  call symputx('result',put(x,hex16.));
run;
data; z=input("&result",hex16.);
put z=;
run;quit;
%mend;

%testexpr;
*/

%put Tom Abernathy message on/off capability;
data _null_;
    call symputx('message_d','&messages.putlog');  /* Use &message_d inside of data steps for execution messages */
    call symputx('message_m','%&messages.put');  /* Use &message_m for compile time messages */
  run;

  %let messages=*;  /* turn messages off */
  %let messages=;   /* turn messages on  */

data _null_;
 call symputx('opassp','47306C6466217368'x,'G');
run;

%let _s=&_r\PROGRA~1\SASHome\SASFoundation\9.4\sas.exe -sysin nul -log nul -work &_r\wrk -rsasuser -autoexec &_r\oto\tut_Oto.sas -nosplash -sasautos &_r\oto -RLANG -config &_r\cfg\sasv9.cfg;

%inc "&_o/utl_perpac.sas"; * almost 50 command macros;

%put AM I HERE;

dm "home;pgm;home;copy pgm_last"; * at stratup recalls last program worked on;


