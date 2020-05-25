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

void convolute(unsigned char * M, unsigned char * W,	int index){
  short k[] = {-1, -1, 0, -1, 0, 1, 0, 1, 1};
  short container = 0;

  container += M[index - 801] * k[0];
  container += M[index - 800] * k[1];
  container += M[index - 799] * k[2];
  container += M[index -   1] * k[3];
  container += M[index +   0] * k[4];
  container += M[index +   1] * k[5];
  container += M[index + 799] * k[6];
  container += M[index + 800] * k[7];
  container += M[index + 801] * k[8];

 container = (container + 3* 255)/6;

  //printf("%hd\n",container);
  W[index] = container;

  //printf("%c\n", W[index]);

}



int findMin(unsigned char * M, int width, int height){
  int min = M[0];

  for( int j = 0; j < height * width; j++){
     if(M[j] < min){
       min = M[j];
     }
  }

  return min;
}

int findMax(unsigned char * M, int width, int height){
  int max = M[0];

  for( int j = 0; j < height * width; j++){
     if(M[j] > max){
       max = M[j];
     }
  }

  return max;
}


void filterC(	unsigned char * M, unsigned char * W,	int width, int height){

  for(int j = 0; j < height; j ++){
    for(int i = 0; i < width; i++){
        if (j > 0 && j < height- 1 && i > 0 && i < width - 1){

          // calculate W[j * 800 + i] = convolution(i,j)
          printf("Index: %d\n", j*800 + i);
          convolute(M, W, j*800 + i);


        }
    }
  }
}
