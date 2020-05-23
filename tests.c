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

short convolute(unsigned char * M, unsigned char * W,	int index){
  short k[] = {-1, -1, 0, -1, 0, 1, 0, 1, 1};
  short container = 0;
  //W[index] += M[]

  /*for(int = 0; i < 9; i++){
    w[index] += M[index - ] k[i];
  }*/
  /*
  printf("W aktualnie: %d", W[index]);
  W[index] += M[index - 801] * k[0];
  printf("W aktualnie: %d, M[index - 801] : %d, k[0]: %d\n", W[index], M[index - 801], k[0]);
  W[index] += M[index - 800] * k[1];
  printf("W aktualnie: %d, M[index - 800] : %d, k[1]: %d\n", W[index], M[index - 800], k[1]);
  W[index] += M[index - 799] * k[2];
  printf("W aktualnie: %d, M[index - 801] : %d, k[2]: %d\n", W[index], M[index - 799], k[2]);
  W[index] += M[index -   1] * k[3];
  printf("W aktualnie: %d, M[index - 801] : %d, k[3]: %d\n", W[index], M[index -   1], k[3]);
  W[index] += M[index +   0] * k[4];
  printf("W aktualnie: %d, M[index - 801] : %d, k[4]: %d\n", W[index], M[index +   0], k[4]);
  W[index] += M[index +   1] * k[5];
  printf("W aktualnie: %d, M[index - 801] : %d, k[5]: %d\n", W[index], M[index +    1], k[5]);
  W[index] += M[index + 799] * k[6];
  printf("W aktualnie: %d, M[index - 801] : %d, k[6]: %d\n", W[index], M[index + 799], k[6]);
  W[index] += M[index + 800] * k[7];
  printf("W aktualnie: %d, M[index - 801] : %d, k[7]: %d\n", W[index], M[index + 800], k[7]);
  W[index] += M[index + 801] * k[8];
  printf("W aktualnie: %d, M[index - 801] : %d, k[8]: %d\n", W[index], M[index + 801], k[8]);

  //W = <0,222>
  // Max w possible is 666
  // W(a) = a/3
  W[index] = W[index]/3;
  */
  //printf("W aktualnie: %d", W[index]);
  container += M[index - 801] * k[0];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[0]: %d\n", container, M[index - 801], k[0]);
  container += M[index - 800] * k[1];
  //printf("W aktualnie: %d, M[index - 800] : %d, k[1]: %d\n", container, M[index - 800], k[1]);
  container += M[index - 799] * k[2];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[2]: %d\n", container, M[index - 799], k[2]);
  container += M[index -   1] * k[3];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[3]: %d\n", container, M[index -   1], k[3]);
  container += M[index +   0] * k[4];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[4]: %d\n", container, M[index +   0], k[4]);
  container += M[index +   1] * k[5];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[5]: %d\n", container, M[index +    1], k[5]);
  container += M[index + 799] * k[6];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[6]: %d\n", container, M[index + 799], k[6]);
  container += M[index + 800] * k[7];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[7]: %d\n", container, M[index + 800], k[7]);
  container+= M[index + 801] * k[8];
  //printf("W aktualnie: %d, M[index - 801] : %d, k[8]: %d\n", container, M[index + 801], k[8]);
  // if(container < 0) container = 0;
  //container = (container + 3* 256)/6;
  container = (container + 484)/(5);
  printf("%hd\n",container);
  W[index] = container;

  //printf("%c\n", W[index]);
  return container;

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


void drawHorizontalLine(unsigned char * M, unsigned char * W, int width, int height){

   for( int j = 0; j < height; j++){
      for ( int i = 0; i < width; i++){
          if(j == 320){
            M[j * 800  + i ] = 0;
         }
      }

  }
}

void filterC(	unsigned char * M, unsigned char * W,	int width, int height){
  short max = -24242;
  short min = 24242;
  short x = 0;
  for(int j = 0; j < height; j ++){
    for(int i = 0; i < width; i++){
        if (j > 0 && j < height- 1 && i > 0 && i < width - 1){

          // calculate W[j * 800 + i] = convolution(i,j)
          //printf("Index: %d\n", j*800 + i);
          x = convolute(M, W, j*800 + i);
          if( x > max){
            max =x;
          }
          if(x < min){
            min = x;
          }
        }

    }
  }
  printf("Min: %hd, Max: %hd",min,max);
}
