/******************************************************************************
h_swap.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    Swap the proper bytes in the header to read it properly....

Supports:
    4t_cv.cpp
******************************************************************************/

#include "prot.h"

int main_header_swap(Data_file_header **main_header, int i) {
    
    main_header[i][1].nblocks.character[0]=main_header[i][0].nblocks.character[3];
    main_header[i][1].nblocks.character[1]=main_header[i][0].nblocks.character[2];
    main_header[i][1].nblocks.character[2]=main_header[i][0].nblocks.character[1];
    main_header[i][1].nblocks.character[3]=main_header[i][0].nblocks.character[0];
    
    main_header[i][1].ntraces.character[0]=main_header[i][0].ntraces.character[3];
    main_header[i][1].ntraces.character[1]=main_header[i][0].ntraces.character[2];
    main_header[i][1].ntraces.character[2]=main_header[i][0].ntraces.character[1];
    main_header[i][1].ntraces.character[3]=main_header[i][0].ntraces.character[0];
    
    main_header[i][1].np.character[0]=main_header[i][0].np.character[3];
    main_header[i][1].np.character[1]=main_header[i][0].np.character[2];
    main_header[i][1].np.character[2]=main_header[i][0].np.character[1];
    main_header[i][1].np.character[3]=main_header[i][0].np.character[0];
    
    main_header[i][1].ebytes.character[0]=main_header[i][0].ebytes.character[3];
    main_header[i][1].ebytes.character[1]=main_header[i][0].ebytes.character[2];
    main_header[i][1].ebytes.character[2]=main_header[i][0].ebytes.character[1];
    main_header[i][1].ebytes.character[3]=main_header[i][0].ebytes.character[0];
    
    main_header[i][1].tbytes.character[0]=main_header[i][0].tbytes.character[3];
    main_header[i][1].tbytes.character[1]=main_header[i][0].tbytes.character[2];
    main_header[i][1].tbytes.character[2]=main_header[i][0].tbytes.character[1];
    main_header[i][1].tbytes.character[3]=main_header[i][0].tbytes.character[0];
    
    main_header[i][1].bbytes.character[0]=main_header[i][0].bbytes.character[3];
    main_header[i][1].bbytes.character[1]=main_header[i][0].bbytes.character[2];
    main_header[i][1].bbytes.character[2]=main_header[i][0].bbytes.character[1];
    main_header[i][1].bbytes.character[3]=main_header[i][0].bbytes.character[0];
    
    main_header[i][1].transf.character[0]=main_header[i][0].transf.character[1];
    main_header[i][1].transf.character[1]=main_header[i][0].transf.character[0];
    
    main_header[i][1].status.character[0]=main_header[i][0].status.character[1];
    main_header[i][1].status.character[1]=main_header[i][0].status.character[0];
    
    main_header[i][1].spare1.character[0]=main_header[i][0].spare1.character[3];
    main_header[i][1].spare1.character[1]=main_header[i][0].spare1.character[2];
    main_header[i][1].spare1.character[2]=main_header[i][0].spare1.character[1];
    main_header[i][1].spare1.character[3]=main_header[i][0].spare1.character[0];
    
    main_header[i][0]=main_header[i][1];
    
    return 1;
}

int block_header_swap(Data_block_header **block_header, int i) {
    
    block_header[i][1].scale.character[0]=block_header[i][0].scale.character[1];
    block_header[i][1].scale.character[1]=block_header[i][0].scale.character[0];
    
    block_header[i][1].status.character[0]=block_header[i][0].status.character[1];
    block_header[i][1].status.character[1]=block_header[i][0].status.character[0];
    
    block_header[i][1].index.character[0]=block_header[i][0].index.character[1];
    block_header[i][1].index.character[1]=block_header[i][0].index.character[0];
    
    block_header[i][1].spare3.character[0]=block_header[i][0].spare3.character[1];
    block_header[i][1].spare3.character[1]=block_header[i][0].spare3.character[0];
    
    block_header[i][1].ctcount.character[0]=block_header[i][0].ctcount.character[3];
    block_header[i][1].ctcount.character[1]=block_header[i][0].ctcount.character[2];
    block_header[i][1].ctcount.character[2]=block_header[i][0].ctcount.character[1];
    block_header[i][1].ctcount.character[3]=block_header[i][0].ctcount.character[0];
    
    block_header[i][1].lpval.character[0]=block_header[i][0].lpval.character[3];
    block_header[i][1].lpval.character[1]=block_header[i][0].lpval.character[2];
    block_header[i][1].lpval.character[2]=block_header[i][0].lpval.character[1];
    block_header[i][1].lpval.character[3]=block_header[i][0].lpval.character[0];
    
    block_header[i][1].rpval.character[0]=block_header[i][0].rpval.character[3];
    block_header[i][1].rpval.character[1]=block_header[i][0].rpval.character[2];
    block_header[i][1].rpval.character[2]=block_header[i][0].rpval.character[1];
    block_header[i][1].rpval.character[3]=block_header[i][0].rpval.character[0];
    
    block_header[i][1].lvl.character[0]=block_header[i][0].lvl.character[3];
    block_header[i][1].lvl.character[1]=block_header[i][0].lvl.character[2];
    block_header[i][1].lvl.character[2]=block_header[i][0].lvl.character[1];
    block_header[i][1].lvl.character[3]=block_header[i][0].lvl.character[0];
    
    block_header[i][1].tlt.character[0]=block_header[i][0].tlt.character[3];
    block_header[i][1].tlt.character[1]=block_header[i][0].tlt.character[2];
    block_header[i][1].tlt.character[2]=block_header[i][0].tlt.character[1];
    block_header[i][1].tlt.character[3]=block_header[i][0].tlt.character[0];
    
    block_header[i][0]=block_header[i][1];
    
    return 1;
}
