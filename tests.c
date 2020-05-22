#include<stdio.h>

void drawVerticalLine(unsigned char * M, unsigned char * W, int width, int height){

   for( int j = 0; j < height; j++){
      for ( int i = 0; i < width; i++){
          if(i == 400){
           M[i + j*(800)] = 0;
         }
      }

  }
}

void drawHorizontalLine(unsigned char * M, unsigned char * W, int width, int height){

   for( int j = 0; j < height; j++){
      for ( int i = 0; i < width; i++){
          if(j == 320){
            M[j * 800  + i ] = 0;
         }
      }

  }
}
