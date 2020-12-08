#include "mex.h"
#include "matrix.h"
#include <math.h>

/* Input Arguments */

#define	IMGSTACK       prhs[0]
#define INITPOS        prhs[1]
#define THRESHOLD      prhs[2]
#define MAXDIST        prhs[3]
/* KIEGESZÍTES
#define ROUGHTREE      prhs[4]
#define BINARYMASK     prhs[5]
KIEGESZÍTES*/

/* Output Arguments */

#define SEGRES         plhs[0]

/* Queue struct */

struct node
{
    int data[3];
    struct node *next;
};

/* Prototypes */
bool isValidDist(int xCurr,int yCurr,int zCurr,int xSeed,int ySeed,int zSeed,double maxDist);
double getVal(int rows,int cols,double *arr3D,int x,int y,int z);
void setVal(int rows,int cols,double *arr3D,int x,int y,int z);
void enqueue(struct node **front,struct node **rear,int item[3]);
void dequeue(struct node **front,struct node **rear);

/* Mex Function entry point and input assertion */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    /* Check for proper number of arguments */

	if (nrhs != 4) {
		mexErrMsgIdAndTxt("MATLAB:regGrow:invalidNumInputs",
			"Invalid number of input arguments");
	}
	else if (nlhs > 1) {
		mexErrMsgIdAndTxt("MATLAB:regGrow:maxlhs",
			"Too many output arguments.");
	}
    
    /* Assert inputs (check the mx-Functions in Matlab documentation) */
	if (!mxIsDouble(IMGSTACK) ||
		mxIsComplex(IMGSTACK)){
		mexErrMsgIdAndTxt("MATLAB:regGrow:notDouble",
			"First input must be a real double.");
	}
	
	int nDimNum = mxGetNumberOfDimensions(IMGSTACK);
	const mwSize *pDims;
	pDims = mxGetDimensions(IMGSTACK);
    
    if (nDimNum != 3) {
		mexErrMsgIdAndTxt("MATLAB:regGrow:inputNot3DArray",
			"First input must be a 3D array.");
	}
    
    if ((pDims[0] <= 1) ||
        (pDims[1] <= 1) ||
        (pDims[2] <= 1)){
		mexErrMsgIdAndTxt("MATLAB:regGrow:inputNot3DArray",
			"First input must be a 3D array.");
    }
    
    if (!mxIsDouble(INITPOS) ||
		mxIsComplex(INITPOS) ||
		(mxGetNumberOfElements(INITPOS) != 3) ||
        (mxGetM(INITPOS) != 1)){
		mexErrMsgIdAndTxt("MATLAB:regGrow:notVector",
			"Second input must be a vector.");
	}
    
    if (!mxIsDouble(THRESHOLD) ||
		mxIsComplex(THRESHOLD) ||
		mxGetNumberOfElements(THRESHOLD) != 1) {
		mexErrMsgIdAndTxt("MATLAB:regGrow:notScalar",
			"Third input must be a scalar.");
	}
    
    if (!mxIsDouble(MAXDIST) ||
		mxIsComplex(MAXDIST) ||
		mxGetNumberOfElements(MAXDIST) != 1) {
		mexErrMsgIdAndTxt("MATLAB:regGrow:notScalar",
			"Fourth input must be a scalar.");
	}
    
    /* Prepare inputs and output */
    double *imgStack = mxGetPr(IMGSTACK);/* Get pointer to input image */
    /* KIEGESZÍTES
    double *roughTree = mxGetPr(ROUGHTREE);
    double *binaryMask = mxGetPr(BINARYMASK);
    KIEGESZÍTES */
    SEGRES = mxCreateNumericArray(nDimNum,pDims,mxDOUBLE_CLASS,mxREAL);/* allocate memory for output image */
    double *segRes = mxGetPr(SEGRES);/* Get pointer to output image */
    
    int initPos[3];/* Get initial position from pointer */
    initPos[0] = (int) (mxGetPr(INITPOS))[0] - 1;/* Subtract 1 because of the different indexing in c */
    initPos[1] = (int) (mxGetPr(INITPOS))[1] - 1;
    initPos[2] = (int) (mxGetPr(INITPOS))[2] - 1;
    
    double thresVal = mxGetScalar(THRESHOLD);/* Get threshold from pointer */
    double regVal = getVal(pDims[0],pDims[1],imgStack,initPos[0],initPos[1],initPos[2]);/* Get value of the seed point */
    
    double maxDistance = mxGetScalar(MAXDIST);
    if (!mxIsFinite(maxDistance))
    {
        maxDistance = INFINITY;
    }
    
    /* Prepare queue and algorithm */
    struct node *fEl = NULL;
    struct node *rEl = NULL;
    
    enqueue(&fEl,&rEl,initPos);/* Put the seed point to the queue*/
    int xv,yv,zv;
    int i, j, k;
    int newItem[3] = { 0 };
    struct node *currFront;
    
    /* Region growing algorithm */
    while(fEl != NULL)/* while there are elements in the queue */
    {
        currFront = fEl;/* current element is the first queue element */
        xv = currFront->data[0];/* get the coordinates */
        yv = currFront->data[1];
        zv = currFront->data[2];
        dequeue(&fEl,&rEl);
        /* Loop over the neighbors */
        for(i=-1;i<=1;i++){
            for(j=-1;j<=1;j++){
                for(k=-1;k<=1;k++){
                    /* Check if the current neighbor is connected to the region */
                    if((xv+i >= 0) && (xv+i < pDims[0]) &&
                       (yv+j >= 0) && (yv+j < pDims[1]) &&
                       (zv+k >= 0) && (zv+k < pDims[2]) &&
                       !((i == 0) && (j == 0) && (k ==0)) && 
                       (getVal(pDims[0],pDims[1],segRes,xv+i,yv+j,zv+k) == 0) &&     
                       (getVal(pDims[0],pDims[1],imgStack,xv+i,yv+j,zv+k) <= (regVal + thresVal)) &&
                       (getVal(pDims[0],pDims[1],imgStack,xv+i,yv+j,zv+k) >= (regVal - thresVal))&&
                       isValidDist(xv+i,yv+j,zv+k,initPos[0],initPos[1],initPos[2],maxDistance)) /* KIEGESZÍTES
                            ((getVal(pDims[0],pDims[1],roughTree,xv+i,yv+j,zv+k) == 1) ||
                            (getVal(pDims[0],pDims[1],binaryMask,xv+i,yv+j,zv+k) == 1))) KIEGESZÍTES */
                    {
                        /* Set this pixel in the result array */
                        setVal(pDims[0],pDims[1],segRes,xv+i,yv+j,zv+k);
                        newItem[0] = xv+i;
                        newItem[1] = yv+j;
                        newItem[2] = zv+k;
                        /* And add it to the queue */
                        enqueue(&fEl,&rEl,newItem);
                    }  
                }
            }
        }
    }
    /* Return results to Matlab workspace */
    return;
}

/* Function to get distance between the current point and the seed */
bool isValidDist(int xCurr,int yCurr,int zCurr,int xSeed,int ySeed,int zSeed,double maxDist)
{
    double dx = (double) (xCurr - xSeed);
    double dy = (double) (yCurr - ySeed);
    double dz = (double) (zCurr - zSeed);
    return(sqrt(dx*dx + dy*dy + dz*dz) < maxDist);
}

/* Function to get a pixel value */
double getVal(int rows,int cols,double *arr3D,int x,int y,int z)
{
    return(arr3D[(x)+((y)+(z)*cols)*rows]);
}

/* Function to set a pixel value */
void setVal(int rows,int cols,double *arr3D,int x,int y,int z)
{
    arr3D[(x)+((y)+(z)*cols)*rows] = 1;
}

/* Function to enqueue new pixel coordinates */
void enqueue(struct node **front,struct node **rear,int item[3])
{
    struct node *nptr = malloc(sizeof(struct node));
    nptr->data[0] = item[0];
    nptr->data[1] = item[1];
    nptr->data[2] = item[2];
    nptr->next = NULL;
    if (*rear == NULL)
    {
        *front = nptr;
        *rear = nptr;
    }
    else
    {
        (*rear)->next = nptr;
        *rear = (*rear)->next;
    }
}

/* Function to delete the first element of the queue */
void dequeue(struct node **front,struct node **rear)
{
    if (*front != NULL)
    {
        struct node *temp;
        temp = *front;
        *front = (*front)->next;
        if(*front == NULL)
        {
            *rear = NULL;
        }
        free(temp);
    }
}